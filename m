From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 16:53:44 -0700
Message-ID: <7a363b93-bf14-9a13-d154-42a26ac06a06@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
 <588E80DB.3070209@cumulusnetworks.com>
 <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com>
 <588EA2E8.2040302@cumulusnetworks.com>
 <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
 <588F607D.2050600@cumulusnetworks.com>
 <d987faff-ced4-8791-8bdb-ba8a66aec6f5@cumulusnetworks.com>
 <588F89E5.9060503@cumulusnetworks.com> <20170130131600.00c21eb3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Stephen Hemminger <stephen@networkplumber.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35438 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbdA3Xyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 18:54:50 -0500
Received: by mail-pf0-f178.google.com with SMTP id f144so95330796pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 15:53:46 -0800 (PST)
In-Reply-To: <20170130131600.00c21eb3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 2:16 PM, Stephen Hemminger wrote:
> My fear is that routing daemons already adapt to the funny semantics of multi-path routing in IPv4 vs IPv6
> and therefore any change in semantics or flags risks breaking existing user space.

That is a possibility, but so far the 2 open source code bases I know of have problems with IPv6 mpath.

As I mentioned quagga does not work with IPv6 multipath as is today. 

I just looked at bird. IPv6 mpath support was added in Sept. 2016. It specifically hard codes not accepting RTA_MULTIPATH for IPv6 which I think is an odd choice and clearly coding to quirks as opposed to rtnetlink design. Having never looked at bird code I was able to get it working in < 1 hour. I will contact the patch author about that limitation. That said, the bird implementation needs work when you look at the add/delete/replace/append permutations, so the current code has its problems as well.
