From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Mon, 1 Nov 2004 15:59:44 -0600
Message-ID: <20041101215944.GB17279@lists.us.dell.com>
References: <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com> <20041101202754.GA23149@gondor.apana.org.au> <20041101203821.GA15086@lists.us.dell.com> <20041101204131.GA23277@gondor.apana.org.au> <20041101204533.GA17279@lists.us.dell.com> <1099345849.1073.1.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099345849.1073.1.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 04:50:49PM -0500, jamal wrote:
> My onluy comment is on use of -EOVERFLOW which i have seen only
> being used in the context of floating point computation
> (same as -EUNDERFLOW). I dont know what the right thing to return would
> be.

Actually, -EOVERFLOW appears throughout the kernel.  A couple examples:

drivers/net/ppp_generic.:ppp_read() uses it to indicate skb->len >
sizeof buffer to put the data into.

fs/stat.c:cp_new_stat() and friends
    if (stat->size > MAX_NON_LFS)
          return -EOVERFLOW;
indicates that the file size is larger than can be represented by the app.

I believe our use would be consistent.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
