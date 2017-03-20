From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Mon, 20 Mar 2017 15:04:46 -0400
Message-ID: <31a8e038-f0b8-6854-6ab9-288a79ff91d0@timesys.com>
References: <1489785040-26477-1-git-send-email-akshay.bhat@timesys.com>
 <1489785040-26477-2-git-send-email-akshay.bhat@timesys.com>
 <78bf099d-32ad-9981-6ba9-fe56fbcabc3e@grandegger.com>
 <7f768a65-bdf0-3b43-17e8-9aaca5997663@timesys.com>
 <86fb20f6-8a3a-163f-9dc6-ba7f5368b689@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <86fb20f6-8a3a-163f-9dc6-ba7f5368b689-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 03/20/2017 12:46 PM, Wolfgang Grandegger wrote:
..snip..
>>
>> The top 3 bits of HI3110_READ_ERR (BUSOFF, TXERRP, RXERRP) are valid
>> even if HI3110_INT_BUSERR is not set.
> 
> I'm confused! If you disable BUSERR interrupts, you do not get the
> status bits any longer, you said. But the manual says: "Bits 4:0 in the
> ERR register can be read to determine the source of the error.", which
> excludes the above bits... but obviously the controller does it that way.
> 

I agree this feature could use better documentation.

Based on testing:

If BUSERRIE bit in INTE is clear,
On cable disconnect: No interrupts related to bus errors are generated.
So status change messages do not go out.

If BUSERRIE bit in INTE is set,
On cable disconnect: Interrupts are generated due to ACKERR. The
interrupt routine reads the BUSOFF/TXERRP/RXERRP bits of ERR register
and reports the state. If CAN_CTRLMODE_BERR_REPORTING is set, then
protocol errors are also reported by the interrupt.
On cable re-connect: Interrupts are generated due to TXCPLT. The
interrupt routine reads the BUSOFF/TXERRP/RXERRP bits of ERR register
and reports the state.

Let me know if this helps clear things up :)



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
