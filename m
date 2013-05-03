From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 3 May 2013 09:20:21 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7222@saturn3.aculab.com>
References: <1367370761.11020.22.camel@edumazet-glaptop> <20130501115103.58e40f37@kryten> <1367375060.11020.24.camel@edumazet-glaptop> <20130501035425.GD5221@bubble.grove.modra.org> <1367384672.11020.34.camel@edumazet-glaptop> <20130503013136.GN5221@bubble.grove.modra.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Anton Blanchard" <anton@samba.org>,
	"David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	"Paul Mackerras" <paulus@samba.org>,
	"Ambrose Feinstein" <ambrose@google.com>
To: "Alan Modra" <amodra@gmail.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51747 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751165Ab3ECIV0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 04:21:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31412-06 for <netdev@vger.kernel.org>;
 Fri,  3 May 2013 09:21:19 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130503013136.GN5221@bubble.grove.modra.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Did someone fix btrfs, but not check other kernel locks?  Having now
> hit the same problem again, have you checked that other kernel locks
> don't have adjacent bit fields in the same 64-bit word?  And comment
> the struct to ensure someone doesn't optimize those unsigned chars
> back to bit fields.

Seems a good reason to have a general policy of not using
bit fields!

Separate char fields normally generate faster code - possibly
at the expense of an increase in the allocated size of a
structure.

	David
