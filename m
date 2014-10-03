From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v3 net-next 3/3] bridge: Add filtering support
	for default_pvid
Date: Fri, 03 Oct 2014 09:37:27 -0400
Message-ID: <542EA697.7070109@redhat.com>
References: <1412294070-11930-1-git-send-email-vyasevic@redhat.com>	<1412294070-11930-4-git-send-email-vyasevic@redhat.com>
	<CAHA+R7OycteYron5K3YJ3qtsEE-5uUxhPkictJDWosXCihR5hA@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>
To: Cong Wang <cwang@twopensource.com>,
	Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHA+R7OycteYron5K3YJ3qtsEE-5uUxhPkictJDWosXCihR5hA@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 10/03/2014 12:41 AM, Cong Wang wrote:
> On Thu, Oct 2, 2014 at 4:54 PM, Vladislav Yasevich <vyasevich@gmail.com> wrote:
>> +static void br_vlan_disable_default_pvid(struct net_bridge *br)
>> +{
>> +       struct net_bridge_port *p;
>> +       u16 pvid = br->default_pvid;
>> +
>> +       /* Disable default_pvid on all ports where it is still
>> +        * configured.
>> +        */
>> +
> 
> This empty line is not necessary.
> 
>> +       if (vlan_default_pvid(br_get_vlan_info(br), pvid))
>> +               br_vlan_delete(br, pvid);
>> +
>> +       list_for_each_entry(p, &br->port_list, list) {
>> +               if (vlan_default_pvid(nbp_get_vlan_info(p), pvid))
>> +                       nbp_vlan_delete(p, pvid);
>> +       }
>> +
>> +       br->default_pvid = 0;
>> +}
>> +
>> +static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
>> +{
>> +       struct net_bridge_port *p;
>> +       u16 old_pvid;
>> +       int err;
>> +       DECLARE_BITMAP(changed, BR_MAX_PORTS);
> 
> 
> This bitmap will use 128 bytes on stack, why not using heap?
> 

I suppose I wanted to avoid yet another memory allocation failure condition.
Is this really going to cause issues?

Thanks
-vlad


>> +
>> +       bitmap_zero(changed, BR_MAX_PORTS);
>> +
>> +       /* This function runs with filtering turned off so we can
>> +        * remove the old pvid configuration and add the new one after
>> +        * without impacting traffic.
>> +        */
>> +
>> +       old_pvid = br->default_pvid;
> 
> 
> Remove the empty line.
> 
> [...]
> 
>> +int nbp_vlan_init(struct net_bridge_port *p)
>> +{
>> +       int rc = 0;
>> +
>> +       if (p->br->default_pvid) {
>> +               rc = nbp_vlan_add(p, p->br->default_pvid,
>> +                                 BRIDGE_VLAN_INFO_PVID |
>> +                                 BRIDGE_VLAN_INFO_UNTAGGED);
>> +       }
>> +
>> +       return rc;
>> +}
> 
> 'rc' can be removed.
> 
