From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] reduce stack usage in ixgb_ethtool_ioctl
Date: Sun, 19 Sep 2004 14:26:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414DCF60.1070104@pobox.com>
References: <200409192033.56716.vda@port.imtp.ilyichevsk.odessa.ua> <1095618283.4870.0.camel@dillow.idleaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Dillow <dave@thedillows.org>
In-Reply-To: <1095618283.4870.0.camel@dillow.idleaire.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Dillow wrote:
> On Sun, 2004-09-19 at 13:33, Denis Vlasenko wrote:
> 
>>Stack usage is still high because gcc will
>>allocate too much space for these cases:
>>
>>        case ETHTOOL_GSET:{
>>                        struct ethtool_cmd ecmd = { ETHTOOL_GSET };
>>                        ixgb_ethtool_gset(adapter, &ecmd);
>>                        if (copy_to_user(addr, &ecmd, sizeof(ecmd)))
>>                                return -EFAULT;
>>                        return 0;
>>                }
>>        case ETHTOOL_SSET:{
>>                        struct ethtool_cmd ecmd;
>>                        if (copy_from_user(&ecmd, addr, sizeof(ecmd)))
>>                                return -EFAULT;
>>                        return ixgb_ethtool_sset(adapter, &ecmd);
>>                }
>>
>>There will be space for _two_ ecmd's on stack.
>>
>>Shall it be worked around with ugly union of structs
>>or we'll just wait for better gcc?
> 
> 
> You could convert it to use ethtool_ops.

Check -mm to make sure viro hasn't already converted it to ethtool_ops...

	Jeff
