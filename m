From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net : Remove unnecessary assignments
Date: Tue, 18 Mar 2014 16:22:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E0472@AcuExch.aculab.com>
References: <53287010.8000703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Balakumaran Kannan' <kumaran.4353@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35428 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751308AbaCRQYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:24:03 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31797-01 for <netdev@vger.kernel.org>;
 Tue, 18 Mar 2014 16:24:00 +0000 (GMT)
In-Reply-To: <53287010.8000703@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Behalf Of Balakumaran Kannan
> Remove unnecessary assignments
> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> ---
> Some unnecessary assignments has been removed from devinet_ioctl function.
> The 'ret' variable is set in multiple places, but used only based on if
> conditions. So keeping the assignment inside if will be a better.
...

These all seem to be this transform:
> -	ret = -ENODEV;
>  	dev = __dev_get_by_name(net, ifr.ifr_name);
> -	if (!dev)
> +	if (!dev) {
> +		ret = -ENODEV;
>  		goto done;
> +	}

I bet that if you look at the generated code you'll find
that the compiler generates the same code for both forms
and is likely to generate the equivalent of:
	dev = __dev_get_by_name(net, ifr.ifr_name);
	ret = -ENODEV;
	if (!dev)
		goto done;

So this is just a matter of style.

	David
