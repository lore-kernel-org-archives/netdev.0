From: Dave Watson <davejwatson@fb.com>
Subject: Re: Kernel TLS in 4.13-rc1
Date: Mon, 24 Jul 2017 14:10:19 -0700
Message-ID: <20170724211019.GA88539@davejwatson-mba.local>
References: <1777546b-3ce0-7714-1388-fb2e6db9320f@sigma-star.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Richard Weinberger <richard@nod.at>
To: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47913 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755920AbdGXVKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:10:32 -0400
Content-Disposition: inline
In-Reply-To: <1777546b-3ce0-7714-1388-fb2e6db9320f@sigma-star.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/17 09:39 PM, David Oberhollenzer wrote:
> After fixing the benchmark/test tool that the patch description
> linked to (https://github.com/Mellanox/tls-af_ktls_tool) to make
> sure that the server and client actually *agree* on AES-128-GCM,
> I simply ran the client program with the --verify-sendpage option.
> 
> The handshake and setting up of the sockets appears to work but
> the program complains that the sent and received page contents
> do not match (sent is 0x12 repeated all over and received looks
> pretty random).

The --verify functions depend on the RX path as well, which has not
been merged.  Any programs / tests using OpenSSL + patches should work
fine.

If you want to use the tool, something like this should work, so that
the receive path uses gnutls:

./server --no-echo

./client --server-port 12345 --sendfile some_file --server-host localhost
