From: Moni Shoua <monis@voltaire.com>
Subject: Re: [PATCH]: net/bonding: Enable to change device type before enslaving
Date: Sun, 13 Apr 2008 17:09:20 +0300
Message-ID: <48021410.5040806@voltaire.com>
References: <47FE2DBF.7080803@voltaire.com> <21771.1207860504@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:36455 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757322AbYDMOJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 10:09:33 -0400
In-Reply-To: <21771.1207860504@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 	Does this mean that the automatic selection on first enslavement
> is no longer needed, and all setting of the type for IB devices must
> occur prior to first enslavement?
> 
> 	Or is this more of a special case for some devices, and the
> automatic selection is still correct for most cases?
> 

I think that the later is closer to the truth. 
The goal is to modify the bonding module to work with IPoIB slaves but
with as small as possible changes to what already exists.

In details, the bonding net device device gets its type by ether_setup(),
which runs for all types of slaves and I don't see a way to change that.
However, bonding master for IPoIB slaves requires a different device type setting 
before it comes up for some OSs (redhat 4 for instance). On other OSs I don't see the problem 
and I guess that this is because master becomes up only after it has slaves.



