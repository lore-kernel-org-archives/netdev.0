From: Andi Kleen <ak@suse.de>
Subject: Re: Route cache performance under stress
Date: Fri, 23 May 2003 10:21:13 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030523102113.4fe38159.ak@suse.de>
References: <20030522.015815.91322249.davem@redhat.com>
	<20030522.034058.71558626.davem@redhat.com>
	<1053602138.9475.34.camel@tux.rsn.bth.se>
	<20030522.180152.15252868.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030522.180152.15252868.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 22 May 2003 18:01:52 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Martin Josefsson <gandalf@wlug.westbo.se>
>    Date: 22 May 2003 13:15:39 +0200
> 
>    On Thu, 2003-05-22 at 12:40, David S. Miller wrote:
>    
>    > +static unsigned long size_to_order(unsigned long size)
>    
>    Any reason you're not using get_order() ?
> 
> Actually, get_order() aparently only works on powers of
> two, which 'size' is definitely not.

Are you sure? I always used it on all kinds of sizes.

The algorithm looks for me like it works on any size. A quick test
confirms that too.

(i386 version)
static __inline__ int get_order(unsigned long size)
{
        int order;

        size = (size-1) >> (PAGE_SHIFT-1);
        order = -1;
        do {
                size >>= 1;
                order++;
        } while (size);
        return order;
}


-Andi
> 
