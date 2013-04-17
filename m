From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 4/9] net: sctp: sctp_outq: consolidate chars into bitfield
Date: Wed, 17 Apr 2013 09:43:45 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71DC@saturn3.aculab.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com> <1366146438-8815-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: "Daniel Borkmann" <dborkman@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49603 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965940Ab3DQIpT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 04:45:19 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28283-02 for <netdev@vger.kernel.org>;
 Wed, 17 Apr 2013 09:45:16 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1366146438-8815-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  	__u32 outstanding_bytes;
> 
> -	/* Are we doing fast-rtx on this queue */
> -	char fast_rtx;
> -
> -	/* Corked? */
> -	char cork;
> -
> -	/* Is this structure empty?  */
> -	char empty;
> +	__u8 fast_rtx:1,	/* Are we doing fast-rtx on this queue */
> +	     cork:1,		/* Corked? */
> +	     empty:1;		/* Is this structure empty?  */
>  };

Use of bitfields just makes the code slower.
The only real excuse for using them is to reduce the size
of a structure that is allocated a lot.

In the above you are just increasing the padding from
1 byte to 3 bytes.

	David
