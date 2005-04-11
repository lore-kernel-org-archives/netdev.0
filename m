From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Why skbuff.h different for 2.4 and 2.6 kernels?
Date: Mon, 11 Apr 2005 18:01:04 -0300
Message-ID: <39e6f6c705041114012e5a9ebe@mail.gmail.com>
References: <20050411163753.20149.qmail@web52210.mail.yahoo.com>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20050411163753.20149.qmail@web52210.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Apr 11, 2005 1:37 PM, linux lover <linux_lover2004@yahoo.com> wrote:
> hello,
> 1) In 2.4 kernel series skbuff.h has following unions
> for each TCP/IP layer.


>         union {
>                 unsigned char   *raw;
>         } mac;
> 
>  why mac union in 2.6 not have ethernet header? Also
> spxhdr and ipxhdr structures are removed from nh and h
> unions.

Work in progress, the ultimate goal is to get rid of all of these unions and
have just:

        void *transport_header;
        void *network_header;
        void *link_header;

So just set mac.raw directly and cast it to the desired type.

- Arnaldo
