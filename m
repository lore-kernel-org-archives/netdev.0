From: Andy Lutomirski <luto@myrealbox.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Wed, 28 Apr 2004 08:50:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408FD2CB.6000102@myrealbox.com>
References: <20040424050931.14C341D4F@luto.stanford.edu> <408FA6B3.1000805@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@myrealbox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe W Damasio <felipewd@terra.com.br>,
        Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <408FA6B3.1000805@terra.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Felipe W Damasio wrote:

>> +static int rtl8169_get_settings(struct net_device *dev,
>> +                   struct ethtool_cmd *cmd)
>> +{
>> +    struct rtl8169_private *tp = dev->priv;
>> +    void *ioaddr = tp->mmio_addr;
>> +    u8 status = RTL_R8(PHYstatus);
> 
> 
>     IMHO you should hold the device lock here (tp->lock).

Why?  Isn't reading the PHYstatus atomic w.r.t. writing it?  I think the 
lock just needs to be held for writes.

Oh -- there is a race if set_settings is called between the PHYstatus 
read and the rest of the code.  I can't imagine that happening, but it 
wouldn't hurt to take the lock.

Francois, do you want a new patch, or should I wait until you finish 
whatever you're doing?

--Andy
