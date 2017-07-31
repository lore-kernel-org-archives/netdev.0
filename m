From: Dave Watson <davejwatson@fb.com>
Subject: Re: Kernel TLS in 4.13-rc1
Date: Mon, 31 Jul 2017 15:00:00 -0700
Message-ID: <20170731220000.GA93172@dhcp-172-20-173-153.dhcp.thefacebook.com>
References: <1777546b-3ce0-7714-1388-fb2e6db9320f@sigma-star.at>
 <20170724211019.GA88539@davejwatson-mba.local>
 <d68c8999-277e-9eb1-0a5c-ee5eb32e0ef5@sigma-star.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Richard Weinberger <richard@nod.at>
To: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51365 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751157AbdGaWAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 18:00:18 -0400
Content-Disposition: inline
In-Reply-To: <d68c8999-277e-9eb1-0a5c-ee5eb32e0ef5@sigma-star.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/17 11:14 PM, David Oberhollenzer wrote:
> On 07/24/2017 11:10 PM, Dave Watson wrote:
> > On 07/23/17 09:39 PM, David Oberhollenzer wrote:
> >> After fixing the benchmark/test tool that the patch description
> >> linked to (https://github.com/Mellanox/tls-af_ktls_tool) to make
> >> sure that the server and client actually *agree* on AES-128-GCM,
> >> I simply ran the client program with the --verify-sendpage option.
> >>
> >> The handshake and setting up of the sockets appears to work but
> >> the program complains that the sent and received page contents
> >> do not match (sent is 0x12 repeated all over and received looks
> >> pretty random).
> > 
> > The --verify functions depend on the RX path as well, which has not
> > been merged.  Any programs / tests using OpenSSL + patches should work
> > fine.
> > 
> > If you want to use the tool, something like this should work, so that
> > the receive path uses gnutls:
> > 
> > ./server --no-echo
> > 
> > ./client --server-port 12345 --sendfile some_file --server-host localhost
> > 
> 
> Thanks! This appears to work as expected (output from the server matches the
> input from the client and the pcap dumps look fine).
> 
> From briefly browsing through the code of the test tool I was initially under
> the impression that it would generate an error message and terminate if an
> attempt was made at configuring ktls for the RX path.
> 
> Anyway, I already read in the patch description that RX wasn't included yet,
> still requires a few cleanups and would follow at some point.
> 
> Is there currently a "not-so-clean" version of the RX patches floating around
> somewhere that we could take a look at?

I dumped the current state here.  Still plenty rough but at least passes
--verify-transmission for me.

https://github.com/ktls/net_next_ktls/tree/tls_recv_net_next

and config changes to af_ktls-tool

https://github.com/ktls/af_ktls-tool/tree/RX
