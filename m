From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [BK PATCH] [IPV6] Multiple locking fixes/improvements
Date: Tue, 23 Nov 2004 13:09:24 -0500
Message-ID: <41A37CD4.3030503@hp.com>
References: <20041122.223205.14979415.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041122.223205.14979415.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

> ChangeSet@1.2232, 2004-11-23 11:52:57+09:00, yoshfuji@linux-ipv6.org
>  [IPV6] Fix a race when dad completed during shutting down its owner in=
terface.

> +static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
> +{
> +	read_lock_bh(&addrconf_lock);
> +	if (ifp->idev->dead)
> +		goto out;
> +	__ipv6_ifa_notify(event, ifp);
> +out:
> +	read_unlock_bh(&addrconf_lock);
>  }

Not to nitpick, but this is just easier to read:

+static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
+{
+	read_lock_bh(&addrconf_lock);
+	if (!ifp->idev->dead)
+		__ipv6_ifa_notify(event, ifp);
+	read_unlock_bh(&addrconf_lock);
  }

-Brian
