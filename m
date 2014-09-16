From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH 2/3] bridge: Add filtering support for
	default_pvid
Date: Tue, 16 Sep 2014 20:10:11 +0900
Message-ID: <54181A93.2070604@lab.ntt.co.jp>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
	<1410554691-18467-3-git-send-email-vyasevic@redhat.com>
	<5415B27A.2000508@gmail.com> <5417011D.2000301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com, Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5417011D.2000301@redhat.com>
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

On 2014/09/16 0:09, Vlad Yasevich wrote:
> On 09/14/2014 11:21 AM, Toshiaki Makita wrote:
>> (14/09/13 (土) 5:44), Vladislav Yasevich wrote:
>>> Currently when vlan filtering is turned on on the bridge, the bridge
>>> will drop all traffic untill the user configures the filter.  This
>>> isn't very nice for ports that don't care about vlans and just
>>> want untagged traffic.
>>>
>>> A concept of a default_pvid was recently introduced.  This patch
>>> adds filtering support for default_pvid.   Now, ports that don't
>>> care about vlans and don't define there own filter will belong
>>> to the VLAN of the default_pvid and continue to receive untagged
>>> traffic.
>>
>> If user sets pvid, then vid 1 (default_pvid) will become non-pvid but
>> still not be filtered, right?
> 
> Right.
> 
>> vlan_bitmap of default_pvid shouldn't be cleared on setting pvid?
> 
> I can see arguments for both.  Just because the user wishes to set a
> different pvid may not always mean that vlan associated with default pvid
> shouldn't be filtered.  I think it's at user's discretion.  I hesitate
> to do too many things automatically.

On second thought, I agree with you.
It's reasonable that what default_pvid should do is only to set pvid on
adding a bridge/port.

My another concern is how we can disable default_pvid, since this
feature is originally non-existent.

Thanks,
Toshiaki Makita
