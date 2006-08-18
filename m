From: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 15:47:46 +0200
Message-ID: <200608181547.47081.arnd.bergmann@de.ibm.com>
References: <200608181331.19501.ossthema@de.ibm.com> <1155903451.4494.168.camel@laptopd505.fenrus.org> <44E5BFB7.4000400@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <osstklei@de.ibm.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:10198 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751388AbWHRNru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 09:47:50 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <44E5BFB7.4000400@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 August 2006 15:25, Thomas Klein wrote:
> 
> > wow... is this really so large that it warrants a vmalloc()???
> 
> Agreed: Replaced with kmalloc()

My understanding from the previous discussion was that it actually
is a multi-page power of two allocation, so the right choice might
be __get_free_pages() instead of kmalloc, but it probably doesn't
make much of a difference.

You should really do some measurements to see what the minimal
queue sizes are that can get you optimal throughput.

	Arnd <><
