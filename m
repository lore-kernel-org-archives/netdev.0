From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] reduce stack usage in ixgb_ethtool_ioctl
Date: Sun, 19 Sep 2004 21:47:28 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409192147.28268.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200409192033.56716.vda@port.imtp.ilyichevsk.odessa.ua> <1095618283.4870.0.camel@dillow.idleaire.com> <414DCF60.1070104@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Dave Dillow <dave@thedillows.org>
In-Reply-To: <414DCF60.1070104@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >>        case ETHTOOL_GSET:{
> >>                        struct ethtool_cmd ecmd = { ETHTOOL_GSET };
> >>                        ixgb_ethtool_gset(adapter, &ecmd);
> >>                        if (copy_to_user(addr, &ecmd, sizeof(ecmd)))
> >>                                return -EFAULT;
> >>                        return 0;
> >>                }
> >>        case ETHTOOL_SSET:{
> >>                        struct ethtool_cmd ecmd;
> >>                        if (copy_from_user(&ecmd, addr, sizeof(ecmd)))
> >>                                return -EFAULT;
> >>                        return ixgb_ethtool_sset(adapter, &ecmd);
> >>                }
> >>
> >>There will be space for _two_ ecmd's on stack.
> >>
> >>Shall it be worked around with ugly union of structs
> >>or we'll just wait for better gcc?
> >
> > You could convert it to use ethtool_ops.
> 
> Check -mm to make sure viro hasn't already converted it to ethtool_ops...

Admit it: it's a conspiracy. Whenever I take some code to hack on, somebody
else takes care of it before I do ;)
--
vda
