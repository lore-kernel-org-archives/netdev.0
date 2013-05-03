From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch] usbnet: pegasus: endian bug in write_mii_word()
Date: Fri, 3 May 2013 09:23:49 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7223@saturn3.aculab.com>
References: <20130503064420.GA14069@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "Dan Carpenter" <dan.carpenter@oracle.com>,
	"Petko Manolov" <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51891 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751018Ab3ECIZd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 04:25:33 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07329-01 for <netdev@vger.kernel.org>;
 Fri,  3 May 2013 09:25:26 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130503064420.GA14069@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We're only passing the two high bits of an integer.  It works for little
                                  ^^^^ bytes
> endian but not for big endian.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 0969905..03e8a15 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -256,8 +256,9 @@ static int mdio_read(struct net_device *dev, int phy_id, int loc)
>  static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
>  {
>  	pegasus_t *pegasus = netdev_priv(dev);
> +	u16 data = val;
> 
> -	write_mii_word(pegasus, phy_id, loc, (__u16 *)&val);
> +	write_mii_word(pegasus, phy_id, loc, &data);
>  }
> 
>  static int read_eprom_word(pegasus_t *pegasus, __u8 index, __u16 *retdata)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
