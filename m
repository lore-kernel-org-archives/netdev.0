From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: ss: escape all null bytes in abstract unix
 domain socket
Date: Fri, 2 Dec 2016 15:18:10 -0800
Message-ID: <20161202151810.4fab9504@xeon-e3>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
        <20161112101729.4d400929@samsung9>
        <1480705196.18162.381.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Isaac Boukris <iboukris@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480705196.18162.381.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Dec 2016 10:59:56 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sat, 2016-11-12 at 10:17 +0300, Stephen Hemminger wrote:
> > On Sat, 29 Oct 2016 22:20:19 +0300
> > Isaac Boukris <iboukris@gmail.com> wrote:
> >   
> > > Abstract unix domain socket may embed null characters,
> > > these should be translated to '@' when printed by ss the
> > > same way the null prefix is currently being translated.
> > > 
> > > Signed-off-by: Isaac Boukris <iboukris@gmail.com>  
> > 
> > Applied  
> 
> Probably not a good idea to have :
> 
>                        for (int i = 0; i < len; i++)
>                                if (name[i] == '\0')
>                                        name[i] = '@';
> 
> ss.c: In function 'unix_show_sock':
> ss.c:3128:4: error: 'for' loop initial declarations are only allowed in C99 mode
> ss.c:3128:4: note: use option -std=c99 or -std=gnu99 to compile your code
> make[1]: *** [ss.o] Error 1
> 
> 
> 

Thanks, fixed by patch from Simon
