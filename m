From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Wed, 05 Dec 2012 09:26:35 +0800
Message-ID: <50BEA2CB.9000800@asianux.com>
References: <201212040346.qB43kVSQ018028@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:10910 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab2LEBZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 20:25:49 -0500
In-Reply-To: <201212040346.qB43kVSQ018028@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  firstly, sorry for reply late (yesterday I have an annual leave for
some personal things).

  and thank you for your reply, too.


=D3=DA 2012=C4=EA12=D4=C204=C8=D5 11:46, Chas Williams (CONTRACTOR) =D0=
=B4=B5=C0:
>  static ssize_t show_address(struct device *cdev,
>  			    struct device_attribute *attr, char *buf)
>  {
> -	char *pos =3D buf;
>  	struct atm_dev *adev =3D to_atm_dev(cdev);
> -	int i;
> -
> -	for (i =3D 0; i < (ESI_LEN - 1); i++)
> -		pos +=3D sprintf(pos, "%02x:", adev->esi[i]);
> -	pos +=3D sprintf(pos, "%02x\n", adev->esi[i]);
> =20
> -	return pos - buf;
> +	return scnprintf(buf, PAGE_SIZE, "%pM\n", adev->esi);
>  }
> =20

  "%p" seems print a pointer, not contents of pointer (is it correct ?)

  will it change the original display format to outside ?


>  static ssize_t show_atmaddress(struct device *cdev,
>  			       struct device_attribute *attr, char *buf)
>  {
>  	unsigned long flags;
> -	char *pos =3D buf;
>  	struct atm_dev *adev =3D to_atm_dev(cdev);
>  	struct atm_dev_addr *aaddr;
>  	int bin[] =3D { 1, 2, 10, 6, 1 }, *fmt =3D bin;
> -	int i, j;
> +	int i, j, count =3D 0;
> =20
>  	spin_lock_irqsave(&adev->lock, flags);
>  	list_for_each_entry(aaddr, &adev->local, entry) {
>  		for (i =3D 0, j =3D 0; i < ATM_ESA_LEN; ++i, ++j) {
>  			if (j =3D=3D *fmt) {
> -				pos +=3D sprintf(pos, ".");
> +				count +=3D scnprintf(buf + count,
> +						   PAGE_SIZE - count, ".");
>  				++fmt;
>  				j =3D 0;
>  			}
> -			pos +=3D sprintf(pos, "%02x",
> -				       aaddr->addr.sas_addr.prv[i]);
> +			count +=3D scnprintf(buf + count,
> +					   PAGE_SIZE - count, "%02x",
> +					   aaddr->addr.sas_addr.prv[i]);
>  		}
> -		pos +=3D sprintf(pos, "\n");
> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");
>  	}
>  	spin_unlock_irqrestore(&adev->lock, flags);
> =20
> -	return pos - buf;
> +	return count;
>  }
> =20

  need we judge whether count >=3D PAGE_SIZE ?


  these are my suggestions, maybe not correct.

  :-)

  thanks.

--=20
Chen Gang

Asianux Corporation
