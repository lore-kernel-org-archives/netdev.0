From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPU
 load
Date: Tue, 17 Sep 2002 15:45:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D878675.3000403@mandrakesoft.com>
References: <72A87F7160C0994D8C5A36E2FDC227F502B3E70D@txnexc01.americas.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Cureington, Tony" <tony.cureington@hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cureington, Tony wrote:
>                 /* Yes, the mii is overlaid on the ifreq.ifr_ifru */
>                 mii = (struct mii_ioctl_data *)&ifr.ifr_data;
>                 if (ioctl(dev, &ifr, SIOCGMIIPHY) != 0) {
>                         return MII_LINK_READY;   /* can't tell */
>                 }
> 
>                 mii->reg_num = 1;
>                 if (ioctl(dev, &ifr, SIOCGMIIREG) == 0) {
>                         /*
>                          * mii->val_out contains MII reg 1, BMSR
>                          * 0x0004 means link established
>                          */
>                         return mii->val_out;
>                 }


Speaking of bonding, I wonder about the above code -- why do you return 
mii->val_out directly?  AFAICS you should test BMSR_LSTATUS (a.k.a. 
0x0004) and return MII_LINK_READY or zero -- not a bunch of random bits.

The status word can certainly be non-zero even when link is absent.

Also, a further question:  do you have access to the slave struct 
net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all 
that ioctl calling if it returns non-zero.

	Jeff
