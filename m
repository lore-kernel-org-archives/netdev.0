From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: problem setting net.ipvX.conf.all.forwarding via sysctl()
 system call
Date: Fri, 08 Aug 2003 17:45:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808.174504.14391608.yoshfuji@linux-ipv6.org>
References: <20030803154427.GA12926@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jan.oravec@6com.sk
In-Reply-To: <20030803154427.GA12926@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030803154427.GA12926@wsx.ksp.sk> (at Sun, 3 Aug 2003 17:44:27 +0200), Jan Oravec <jan.oravec@6com.sk> says:

> For IPv4, it is because ipv4_sysctl_forward_strategy only copy new value to
> check whether it has changed and does not update ipv4_devconf.forwarding
> before calling inet_forward_change(). (it is copied internally by sysctl
> after ipv4_sysctl_forward_strategy because we return positive number)
> 
> I am not good in kernel parallel computing strategy, whether it requires
> some locking or it is safe to do:
> 
> --- sysctl_net_ipv4.c.old       2003-08-03 17:37:44.000000000 +0200
> +++ sysctl_net_ipv4.c   2003-08-03 17:38:18.000000000 +0200
> @@ -109,8 +109,9 @@ static int ipv4_sysctl_forward_strategy(
>                  }
>          }
>   
> +        ipv4_devconf.forwarding=new;
                                   = new;
>          inet_forward_change();
> -        return 1;
> +        return 0;
>  }
>   
>  ctl_table ipv4_table[] = {

It seems correct, however, this patch cannot apply against 
current tree.  Pleaes resend the patch.
And please make sure to diff like this:
diff -u linux-2.6/net/ipv4/sysctl_net_ipv4.c.old linux-2.6/net/ipv4/sysctl_net_ipv4.c

Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
