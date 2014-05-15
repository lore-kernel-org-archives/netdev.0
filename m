From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 2/8] bridge: Keep track of ports
 capable of automatic discovery.
Date: Thu, 15 May 2014 12:04:14 -0400
Message-ID: <5374E57E.8010708@redhat.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>	<1400080168-16625-3-git-send-email-vyasevic@redhat.com>
	<20140514084251.317ed026@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jhs@mojatatu.com, john.r.fastabend@intel.com, shemminger@vyatta.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140514084251.317ed026@nehalam.linuxnetplumber.net>
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

On 05/14/2014 11:42 AM, Stephen Hemminger wrote:
> On Wed, 14 May 2014 11:09:22 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
>> @@ -58,6 +61,7 @@ static int store_flag(struct net_bridge_port *p, unsigned long v,
>>  
>>  	if (flags != p->flags) {
>>  		p->flags = flags;
>> +		br_port_flags_change(p, old_flags ^ flags);
> 
> You are also xoring twice.
> 

That's wrong...  I've take care of that.

> Why not:
> 
> store_flag()
> 	if (flags != p->flags) {
> 		br_port_flags_change(p, flags);
> 		p->flags = flags;
> 		br_ifinfo_notify(RTM_NEWLINK, p);
> 

This doesn't really make sense as flags_change handler will use current
flag value and that would be wrong.  We'd have to pass the new flags
along, but that doesn't make sense either.

I'll send the update shortly.

Thanks
-vlad
