From: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Subject: Re: Kernel TLS in 4.13-rc1
Date: Sun, 30 Jul 2017 23:14:56 +0200
Message-ID: <d68c8999-277e-9eb1-0a5c-ee5eb32e0ef5@sigma-star.at>
References: <1777546b-3ce0-7714-1388-fb2e6db9320f@sigma-star.at>
 <20170724211019.GA88539@davejwatson-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sigma-star.at ([95.130.255.111]:45996 "EHLO
        mail.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754442AbdG3VO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 17:14:59 -0400
In-Reply-To: <20170724211019.GA88539@davejwatson-mba.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 11:10 PM, Dave Watson wrote:
> On 07/23/17 09:39 PM, David Oberhollenzer wrote:
>> After fixing the benchmark/test tool that the patch description
>> linked to (https://github.com/Mellanox/tls-af_ktls_tool) to make
>> sure that the server and client actually *agree* on AES-128-GCM,
>> I simply ran the client program with the --verify-sendpage option.
>>
>> The handshake and setting up of the sockets appears to work but
>> the program complains that the sent and received page contents
>> do not match (sent is 0x12 repeated all over and received looks
>> pretty random).
> 
> The --verify functions depend on the RX path as well, which has not
> been merged.  Any programs / tests using OpenSSL + patches should work
> fine.
> 
> If you want to use the tool, something like this should work, so that
> the receive path uses gnutls:
> 
> ./server --no-echo
> 
> ./client --server-port 12345 --sendfile some_file --server-host localhost
> 

Thanks! This appears to work as expected (output from the server matches the
input from the client and the pcap dumps look fine).

>From briefly browsing through the code of the test tool I was initially under
the impression that it would generate an error message and terminate if an
attempt was made at configuring ktls for the RX path.

Anyway, I already read in the patch description that RX wasn't included yet,
still requires a few cleanups and would follow at some point.

Is there currently a "not-so-clean" version of the RX patches floating around
somewhere that we could take a look at?


Thanks,

David
