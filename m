From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] gianfar: Fall back to software tcp/udp checksum on
	oldercontrollers
Date: Fri, 28 Jan 2011 09:10:46 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AC2E@saturn3.aculab.com>
References: <640295.36173.qm@web37608.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <640295.36173.qm@web37608.mail.mud.yahoo.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

 
> +		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12)
> +			     && ((unsigned long)fcb % 0x20) > 0x18)) {

You need to check the generated code, but I think you need:

    if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12))
	     && unlikely(((unsigned long)fcb % 0x20) > 0x18))

ie unlikely() around both the primitive comparisons.

	David
