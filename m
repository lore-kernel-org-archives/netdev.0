From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use
 netdev_for_each_mc_addr
Date: Sat, 27 Feb 2010 11:38:37 +0100
Message-ID: <20100227103835.GA2862@psychotron.redhat.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
 <4B862E07.7020002@Voltaire.com>
 <20100225084915.GA3171@psychotron.redhat.com>
 <20100227060146.GA13231@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100227060146.GA13231-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sat, Feb 27, 2010 at 07:01:46AM CET, jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org wrote:
>On Thu, Feb 25, 2010 at 09:49:15AM +0100, Jiri Pirko wrote:
>> Thu, Feb 25, 2010 at 09:00:07AM CET, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org wrote:
>> >Jiri Pirko wrote:
>> >> +++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
>> >> @@ -767,11 +767,8 @@ void ipoib_mcast_dev_flush(struct net_device *dev)
>> >> -static int ipoib_mcast_addr_is_valid(const u8 *addr, unsigned int addrlen,
>> >> -				     const u8 *broadcast)
>> >> +static int ipoib_mcast_addr_is_valid(const u8 *addr, const u8 *broadcast)
>> >>  {
>> >> -	if (addrlen != INFINIBAND_ALEN)
>> >> -		return 0;
>> >
>> >This check was added by commit 5e47596b "IPoIB: Check multicast address format", may I ask what is the reason for removing it now?
>> 
>> Yes, at this very moment the check is not needless but it will be in a brief
>> future. dev_mc_add will look very similar like dev_unicast_add. But ok. Here's
>> patch adding the check in dev_mc_add right now to correct this state. Thanks Or.
>
>Is this enough?
>
>The problem this statement is trying to solve had to do with bonding
>creating multicast addresess for ethernet rather than infiniband in
>some cases. This happens because bonding makes a device that switches
>from ethernet to infiniband during its lifetime. I'm not quite
>sure what kind of life cycle those addresses go through, but if they
>somehow stay on the mc_list then ipoib_mcast_addr_is_valid will still
>need to have the check.
>

Ok I see your point now. But in this case, the length check should be in all
drivers because if for example bonding device changes from infiniband back to
eth, the addresses stored would be "cut" to 6 bytes and would make no sense.

I see two solutions:
1) check the length in all drivers to ensure correctness.
2) when bonding changes it's type, flush mc addresses and start over.

Second option looks nicer to me, but I might be missing something, thouths?

Thanks

Jirka

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
