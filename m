From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core/dev: fix sparse warning
Date: Wed, 04 Feb 2015 04:41:35 -0800
Message-ID: <1423053695.907.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423052746-3688-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423052746-3688-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-02-04 at 12:25 +0000, Lad Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> net/core/dev.c: In function 'validate_xmit_skb_list':
> net/core/dev.c:2720: warning: 'tail' may be used uninitialized in this function
> 
> Although its a false positive, as head is assigned to NULL in the
> beginning, due which later in the loop tail is assigned to skb->prev.
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>  net/core/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ce0d1a..c736467 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2717,7 +2717,7 @@ out_null:
>  
>  struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev)
>  {
> -	struct sk_buff *next, *head = NULL, *tail;
> +	struct sk_buff *next, *head = NULL, *tail = NULL;
>  
>  	for (; skb != NULL; skb = next) {
>  		next = skb->next;

Which gcc/sparse versions are you using ?

I do not see this warning here.

$ gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-linux-gnu/4.8/lto-wrapper
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu
4.8.2-19ubuntu1' --with-bugurl=file:///usr/share/doc/gcc-4.8/README.Bugs
--enable-languages=c,c++,java,go,d,fortran,objc,obj-c++ --prefix=/usr
--program-suffix=-4.8 --enable-shared --enable-linker-build-id
--libexecdir=/usr/lib --without-included-gettext --enable-threads=posix
--with-gxx-include-dir=/usr/include/c++/4.8 --libdir=/usr/lib
--enable-nls --with-sysroot=/ --enable-clocale=gnu
--enable-libstdcxx-debug --enable-libstdcxx-time=yes
--enable-gnu-unique-object --disable-libmudflap --enable-plugin
--with-system-zlib --disable-browser-plugin --enable-java-awt=gtk
--enable-gtk-cairo
--with-java-home=/usr/lib/jvm/java-1.5.0-gcj-4.8-amd64/jre
--enable-java-home
--with-jvm-root-dir=/usr/lib/jvm/java-1.5.0-gcj-4.8-amd64
--with-jvm-jar-dir=/usr/lib/jvm-exports/java-1.5.0-gcj-4.8-amd64
--with-arch-directory=amd64
--with-ecj-jar=/usr/share/java/eclipse-ecj.jar --enable-objc-gc
--enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64
--with-multilib-list=m32,m64,mx32 --with-tune=generic
--enable-checking=release --build=x86_64-linux-gnu
--host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1) 

$ sparse --version
0.4.5-rc1
 
