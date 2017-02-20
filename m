From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v3 1/8] gtp: add documentation
Date: Mon, 20 Feb 2017 17:15:52 +0100
Message-ID: <20170220161552.tnewzagg4z4azikd@nataraja>
References: <20170213153624.14170-1-aschultz@tpip.net>
 <20170213153624.14170-2-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@netfilter.org>, netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        osmocom-net-gprs@lists.osmocom.org, Jonas Bonn <jonas@southpole.se>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:52967 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753281AbdBTQSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:18:21 -0500
Content-Disposition: inline
In-Reply-To: <20170213153624.14170-2-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

this is not really about the documentation, but it still makes sense to
discuss here as the issue is best described:

On Mon, Feb 13, 2017 at 04:36:17PM +0100, Andreas Schultz wrote:
> +Local GTP-U entity and tunnel identification
> +--------------------------------------------
> +
> +GTP-U uses UDP for transporting PDU's. The receiving UDP port is 2152 for
> +GTPv1-U and 3386 for GTPv0-U.
> +
> +There is only one GTP-U entity (and therefor SGSN/GGSN/S-GW/PDN-GW instance)
> +per IP address. Tunnel Endpoint Identifier (TEID) are unique per GTP-U entity.
> +
> +A specific tunnel is only defined by the destination entity. Since the
> +destination port is constant, only the destination IP and TEID define
> +a tunnel. The source IP and Port have no meaning for the tunnel.

Are you absolutely sure about this?

> +[3GPP TS 29.281] Section 4.3.0 defines this so:
> +
> +> The TEID in the GTP-U header is used to de-multiplex traffic incoming from
> +> remote tunnel endpoints so that it is delivered to the User plane entities
> +> in a way that allows multiplexing of different users, different packet
> +> protocols and different QoS levels. Therefore no two remote GTP-U endpoints
> +> shall send traffic to a GTP-U protocol entity using the same TEID value except
> +> for data forwarding as part of mobility procedures.
> +
> +The definition above only defines that two remote GTP-U endpoints *should not*
> +send to the same TEID, it *does not* forbid or exclude such a scenario. In
> +fact, the mentioned mobility procedures make it necessary that the GTP-U entity
> +accepts traffic for TEID's from multiple or unknown peers.

I so far always assumed that you use GTP-C "MODIFY PDP CONTEXT" in case
of such mobility situations, i.e. the control plane explicitly notifies
the GTP-U entity of a change in the SGSN/S-GW address.

At least for 3G this seems to be the case, and my assumption appears to
be confirmed with sources such as e.g. page 15 of
http://www.nwadmin.de/presentation_mobility_manag ement_in_UMTS.pdf

Also, for LTE, it seems that there's a GTPv2-C "Modify Bearer
Request/Response" involved in relocation from one S-GW to another S-GW:
http://www.lteandbeyond.com/2012/03/x2-based-handover-with-sgw-relocation.html

> Step 3. The target Serving GW assigns addresses and TEIDs (one per
> bearer) for downlink traffic from the PDN GW. The Serving GW allocates
> DL TEIDs on S5/S8 even for non-accepted bearers. It sends a Modify
> Bearer Request (Serving GW addresses for user plane and TEID(s))
> message per PDN connection to the PDN GW(s). The SGW also includes
> User Location Information IE and/or UE Time Zone IE if it is present
> in step 2. The PDN GW updates its context field and returns a Modify
> Bearer Response (Charging Id, MSISDN, etc.) message to the Serving GW.
> The MSISDN is included if the PDN GW has it stored in its UE context.
> The PDN GW starts sending downlink packets to the target GW using the
> newly received address and TEIDs. These downlink packets will use the
> new downlink path via the target Serving GW to the target eNodeB. The
> Serving GW shall allocate TEIDs for the failed bearers and inform to
> the MME.

Section 5.5.1.1.3 of TS 23.401 agrees with the GTPv2C signalling during
relocation, AFAICT.

> +Therefor the receiving side only identifies tunnels based on TEID's, not based
> +on the source IP.

I'm wondering if this really is neccesary. Do you have actual protocol
traces, specs or any other literature confirming this?  

I find it somewhat surprising, given how much this opens the door for
arbitrary spoofing from anyone (with access to the respective private
network such as GRX).

So in which situations specifically will thre be a S-GW side Address
change without associated GTP-C signaling informing the P-GW about the
new S-GW side Address + TEID?

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
