From: Wang Jian <lark@linux.net.cn>
Subject: Re: [RFC] dynamic hash table size & xor hash function for cls_fw
Date: Thu, 07 Apr 2005 18:47:08 +0800
Message-ID: <20050407184456.02CC.LARK@linux.net.cn>
References: <20050407005519.GS26731@postel.suug.ch> <1112870307.1118.91.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112870307.1118.91.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi jamal,

I think Thomas decide to only support one hash function at compile time,
and no switch at runtime.

HSIZE is a constant so the if branch will be optimized by gcc at compile
time. only one hash is left.


On 07 Apr 2005 06:38:27 -0400, jamal <hadi@cyberus.ca> wrote:

> On Wed, 2005-04-06 at 20:55, Thomas Graf wrote:
> 
> >  
> >  static __inline__ int fw_hash(u32 handle)
> >  {
> > -	return handle&0xFF;
> > +	if (HTSIZE == 4096)
> > +		return ((handle >> 24) & 0xFFF) ^
> > +		       ((handle >> 12) & 0xFFF) ^
> > +		       (handle & 0xFFF);
> > +	else if (HTSIZE == 2048)
> > +		return ((handle >> 22) & 0x7FF) ^
> > +		       ((handle >> 11) & 0x7FF) ^
> > +		       (handle & 0x7FF);
> > +	else if (HTSIZE == 1024)
> > +		return ((handle >> 20) & 0x3FF) ^
> > +		       ((handle >> 10) & 0x3FF) ^
> > +		       (handle & 0x3FF);
> > +	else if (HTSIZE == 512)
> > +		return (handle >> 27) ^
> > +		       ((handle >> 18) & 0x1FF) ^
> > +		       ((handle >> 9) & 0x1FF) ^
> > +		       (handle & 0x1FF);
> > +	else if (HTSIZE == 256) {
> > +		u8 *t = (u8 *) &handle;
> > +		return t[0] ^ t[1] ^ t[2] ^ t[3];
> > +	} else 
> > +		return handle & (HTSIZE - 1);
> >  }
> 
> Does HTSIZE change at runtime? How does migrating from one to other take
> place? 
> Also why not have a function pointer with a series of these being
> separate instead of doing the if checks? BTW it does seem any one of
> those hashes maybe sufficient, no? 
> 
> cheers,
> jamal



-- 
  lark
