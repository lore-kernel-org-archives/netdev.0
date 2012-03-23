From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Fri, 23 Mar 2012 10:54:14 -0600
Message-ID: <20120323165414.GA15260@obsidianresearch.com>
References: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4@saturn3.aculab.com>
 <88B766C272F2C64B944B21AD078333151C964A66EF@EXMAIL.ad.emulex.com>
 <20120322205824.GC9614@obsidianresearch.com>
 <88B766C272F2C64B944B21AD078333151C964A670B@EXMAIL.ad.emulex.com>
 <3ae9829d-f8dd-4268-918a-94616eff0915@exht1.ad.emulex.com>
 <20120322224429.GA12980@obsidianresearch.com>
 <88B766C272F2C64B944B21AD078333151C964A67E0@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <88B766C272F2C64B944B21AD078333151C964A67E0-/SwythR3zqxVRK6PHKByhFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 23, 2012 at 07:03:37AM -0700, Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org wrote:

> > David is saying you will get a 12 byte struct and fieldb will be unaligned. Since
> > 12 is aligned to 4 no padding is added.
> 
> So I decided to experiment above example before implementing in
> driver. However I find structure of 16 bytes (instead of 12) with
> padding after fielda in below example.  Am I missing some compiler
> option or syntax error in attribute? Sorry to ask this silly
> question.  I tried __attribute__((__aligned__(4))); too based on
> usage in other kernel code.

I got the syntax wrong for that specific case (it is a little
unintuitive.. IMHO, capping the alignment of a container should cap
the alignment of all members, otherwise it is nonsense!):

typedef uint64_t u64_unaligned_8 __attribute__((__aligned__(4)));

struct foo {
        uint32_t fielda;
        u64_unaligned_8 fieldb;
};

struct foo2 {
        uint32_t fielda;
        uint64_t fieldb;
};

int main(int argc,const char *argv[])
{
	printf("sizeof(foo) = %zu, fieldb = %zu\n",sizeof(struct foo),
	       offsetof(struct foo,fieldb));
	printf("sizeof(foo2) = %zu, fieldb = %zu\n",sizeof(struct foo2),
	       offsetof(struct foo2,fieldb));
	return 0;
}

sizeof(foo) = 12, fieldb = 4
sizeof(foo2) = 16, fieldb = 8

gcc version 4.6.1 (Ubuntu/Linaro 4.6.1-9ubuntu3) 

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
