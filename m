From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCHv2 net] i40e: Implement ndo_gso_check()
Date: Mon, 1 Dec 2014 15:47:08 -0800
Message-ID: <CA+mtBx-Q=Ebrx_8NVB5mWURj-oWB3gdNs5fSAL=Frr9sOmyvHw@mail.gmail.com>
References: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
	<CAEP_g=-VEWi2Qo6gcJGr2+NXWEhkuMyu7BiAke6H=x+PTLcNcg@mail.gmail.com>
	<CANr6G5zrA6NUtcyhX1cwEO1Hiq9jnarB36P6m5eoHUFqWWc26Q@mail.gmail.com>
	<CANr6G5xRbG=UnJEdBEN_5ZRjNikCjuUseb1VbQmjjfb36jDP0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	Shannon Nelson <shannon.nelson@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux.nics" <linux.nics@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANr6G5xRbG=UnJEdBEN_5ZRjNikCjuUseb1VbQmjjfb36jDP0g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 1, 2014 at 3:35 PM, Joe Stringer <joestringer@nicira.com> wrote:
> On 21 November 2014 at 09:59, Joe Stringer <joestringer@nicira.com> wrote:
>> On 20 November 2014 16:19, Jesse Gross <jesse@nicira.com> wrote:
>>> I don't know if we need to have the check at all for IPIP though -
>>> after all the driver doesn't expose support for it all (actually it
>>> doesn't expose GRE either). This raises kind of an interesting
>>> question about the checks though - it's pretty easy to add support to
>>> the driver for a new GSO type (and I imagine that people will be
>>> adding GRE soon) and forget to update the check.
>>
>> If the check is more conservative, then testing would show that it's
>> not working and lead people to figure out why (and update the check).
>
> More concretely, one suggestion would be something like following at
> the start of each gso_check():
>
> +       const int supported = SKB_GSO_TCPV4 | SKB_GSO_TCPV6 | SKB_GSO_FCOE |
> +                             SKB_GSO_UDP | SKB_GSO_UDP_TUNNEL;
> +
> +       if (skb_shinfo(skb)->gso_type & ~supported)
> +               return false;

This should already be handled by net_gso_ok.

>
> ..followed by checking the specifics for each. So far the patches have
> only been concerned with further checking on UDP tunnels.
