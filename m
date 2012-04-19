From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX
 sun_path
Date: Thu, 19 Apr 2012 14:11:17 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1204191401250.1153@frira.zrqbmnf.qr>
References: <4F8D497F.8060601@gmail.com> <20120417.223614.629911246108750471.davem@davemloft.net> <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com> <20120418.001650.1042781402985153056.davem@davemloft.net>
 <CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw@mail.gmail.com> <20120419111909.616bef70@pyramind.ukuu.org.uk> <CAKgNAkjZ31JAs0XFutnAozCAcHHAq6pcCAKeDNHccKQ+6uTP6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, w@1wt.eu
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAkjZ31JAs0XFutnAozCAcHHAq6pcCAKeDNHccKQ+6uTP6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thursday 2012-04-19 12:33, Michael Kerrisk (man-pages) wrote:
>
>Anyway, I've dug deeper, looking at hat happens on other platforms.
>It's a mess: the BSDs don't even guarantee  that sun_path is
>null_terminated. So, here's how one has to portably deal with the
>variations:
>
>addrlen = sizeof(struct sockaddr_un);
>cfd = accept(lfd, &addr, &addlen);
>
>printf("%.*s", addrlen - offsetof(struct sockaddr_un, sun_path), addr.sun_path);

What operating system made you write that?


I just ask for fun and the record. Solaris's dirent is also
constructed such that using sizeof(...) is useless.

typedef struct dirent {
        ino_t           d_ino;          /* "inode number" of entry */
        off_t           d_off;          /* offset of disk directory entry */
        unsigned short  d_reclen;       /* length of this record */
        char            d_name[1];      /* name of file */
} dirent_t;
