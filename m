From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6.11-rc4-mm1 patch] fix buggy IEEE80211_CRYPT_* selects
Date: Wed, 2 Mar 2005 22:56:07 +0100
Message-ID: <20050302215607.GF4608@stusta.de>
References: <20050223014233.6710fd73.akpm@osdl.org> <20050226113123.GJ3311@stusta.de> <42256078.1040002@pobox.com> <20050302140833.GD4608@stusta.de> <42261004.4000501@pobox.com> <20050302123829.51dbc44b.akpm@osdl.org> <42262B08.2040401@pobox.com> <20050302131817.2e61805f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050302131817.2e61805f.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2005 at 01:18:17PM -0800, Andrew Morton wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
> >
> > > Thing is, CRYPTO_AES on only selectable on x86.
> > 
> >  You're thinking about CRYPTO_AES_586.  But looking at crypto/Kconfig, 
> >  the dependencies are a bit weird:
> > 
> >  config CRYPTO_AES
> >           tristate "AES cipher algorithms"
> >           depends on CRYPTO && !(X86 && !X86_64)
> >  config CRYPTO_AES_586
> >           tristate "AES cipher algorithms (i586)"
> >           depends on CRYPTO && (X86 && !X86_64)
> 
> That's pretty broken, isn't it?
> 
> Would be better to just do:
> 
> config CRYPTO_AES
> 	select CRYPTO_AES_586 if (X86 && !X86_64)
> 	select CRYPTO_AES_OTHER if !(X86 && !X86_64)
> 
> and hide CRYPTO_AES_586 and CRYPTO_AES_OTHER from the outside world.


  http://www.ussg.iu.edu/hypermail/linux/kernel/0502.3/0518.html
  http://www.ussg.iu.edu/hypermail/linux/kernel/0502.3/0523.html
  

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
