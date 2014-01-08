From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] xen-netback: stop vif thread spinning if
 frontend is unresponsive
Date: Wed, 8 Jan 2014 09:55:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45508D@AcuExch.aculab.com>
References: <1389111929-37231-1-git-send-email-paul.durrant@citrix.com>
 <20140107.162956.1062166230525232035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>
To: 'David Miller' <davem@davemloft.net>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55905 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754477AbaAHJ5A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:57:00 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24201-09 for <netdev@vger.kernel.org>;
 Wed,  8 Jan 2014 09:56:55 +0000 (GMT)
In-Reply-To: <20140107.162956.1062166230525232035.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller
...
> > -	if (!npo.copy_prod)
> > +	if (!npo.copy_prod) {
> > +		if (ring_full)
> > +			vif->rx_queue_stopped = true;
> >  		goto done;
> > +	}
> > +
> > +	vif->rx_queue_stopped = false;
> 
> And then you can code this as:
> 
> 	vif->rx_queue_stopped = (!npo.copy_prod && ring_full);
> 	if (!npo.copy_prod)
> 		goto done;

Which isn't quite the same...
1) It always writes vif->rx_queue_stopped, the old code could
   leave it unchanged.
2) If 'npo' is global then the compiler can't assume that 'vif'
   doesn't alias it so may have to re-read it following the
   write to 'vif->rx_queue_stopped'.

	David
