From: James Carlson <carlson@workingcode.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Fri, 27 Jun 2003 11:27:40 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16124.25196.268015.288718@h006008986325.ne.client2.attbi.com>
References: <20030625.143334.85380461.davem@redhat.com>
	<20030626035824.D68B62C147@lists.samba.org>
	<20030625.205941.41631020.davem@redhat.com>
	<16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
	<20030626190407.S87648@shell.cyberus.ca>
	<16124.11495.374998.153330@h006008986325.ne.client2.attbi.com>
	<16124.13469.944716.441016@nanango.paulus.ozlabs.org>
	<20030627075946.7ab6f591.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, hadi@shell.cyberus.ca, davem@redhat.com,
   rusty@rustcorp.com.au, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: Stephen Hemminger's message of 27 June 2003 07:59:46
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger writes:
> Does LLC allow for re-ordering?

ANSI/IEEE Std 802.2, 1998, section 8.5.2.2 describes a common LLC type
3 simplification that relies on MAC ordering.  This is used on media
(such as Ethernet) that don't reorder.

I believe that LLC type 2 ought to be able to handle misordering and
duplication, at least that's the intent of I-mode frames.  I don't
know if this actually works in all implementations (after all,
Ethernet doesn't reorder, so it's not as if anyone's really had to
test it), but I can check one or two if someone cares.

I'm not sure about LLC type 1.  It appears to expose the client to the
ordering guarantees of the underlying MAC layer, and thus it's very
likely the case that LLC type 1 clients make assumptions about known
MAC types.

-- 
James Carlson                                  <carlson@workingcode.com>
