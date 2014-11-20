From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net 2/5] i40e: Implement ndo_gso_check()
Date: Thu, 20 Nov 2014 12:14:24 -0800
Message-ID: <CAEP_g=8wTikyBq8FSQHM16VKa_n-1vMeSo9MK6N6Wg8pyEQTcQ@mail.gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
 <1415138202-1197-3-git-send-email-joestringer@nicira.com> <CAEP_g=8rbJF5z92LV_c14KooU=i3x=9WpikocctcEUOdw5-oLA@mail.gmail.com>
 <201411201116.04406.joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux.nics@intel.com, Tom Herbert <therbert@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Shannon Nelson <shannon.nelson@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201411201116.04406.joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 11:16 AM, Joe Stringer <joestringer@nicira.com> wrote:
> On Tuesday, November 04, 2014 15:45:22 Jesse Gross wrote:
>> On Tue, Nov 4, 2014 at 1:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
>> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > b/drivers/net/ethernet/intel/i40e/i40e_main.c index c3a7f4a..21829b5
>> > 100644
>> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> > +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
>> > +{
>> > +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
>> > +           (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
>> > +            skb->inner_protocol != htons(ETH_P_TEB) ||
>> > +            skb_inner_mac_header(skb) - skb_transport_header(skb) > 64))
>> > +               return false;
>>
>> I think it may be possible to even support a few more things here.
>> According to the datasheet here:
>> http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/xl71
>> 0-10-40-controller-datasheet.pdf
>>
>> This can actually support 64 bytes beyond the tunnel header, which
>> would make for a total of 80 bytes. It looks like it can also support
>> IPv4 or IPv6 beyond just Ethernet as the encapsulated protocol.
>>
>> Intel guys, can you confirm that this is correct?
>
> I'm just respinning this for v4/6 beyond GRE/UDP tunnel and IPIP, and I found
> the description of max protocol parsing size of 480B (with individual header
> limit of 255B). I couldn't find where you get this 64/80 number or which
> headers it maps to. Could you (or one of the intel guys) expand on this?

The number that I gave was from the section on Geneve support (on page
708), which says that it can support up to 64 bytes of options (this
was also my understanding from previous conversations with Intel
guys). I searched for 480 byte limit and it seems like it for receive
instead of transmit, which could conceivably be different.
