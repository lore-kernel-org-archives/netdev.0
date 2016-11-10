From: Cathy Avery <cavery@redhat.com>
Subject: Re: AF_VSOCK loopback
Date: Thu, 10 Nov 2016 11:17:55 -0500
Message-ID: <58249DB3.7050601@redhat.com>
References: <20161110144329.GA19683@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stefan Hajnoczi <stefanha@redhat.com>,
        Jorgen Hansen <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934058AbcKJQR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 11:17:56 -0500
In-Reply-To: <20161110144329.GA19683@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had trouble with loopback on the esx host. Using the nc-vsock ( 
AF_VSOCK 56 ) the server and the client connected but they both 
terminated without error when I attempted to send characters over. It 
might be due to something other than vsock. I haven't pursued it yet.

On 11/10/2016 09:43 AM, Stefan Hajnoczi wrote:
> Hi Jorgen,
> Cathy Avery found that the AF_VSOCK VMCI transport does loopback inside
> the guest (but not on the host?).  The virtio transport currently does
> no loopback.
>
> The loopback scenario I'm thinking of is where process A listens on port
> 1234 and process B on the same machine connects to port 1234 both with
> the same CID.
>
> I'd like to make the virtio transport compatible with VMCI transport
> semantics so AF_VSOCK behaves the same regardless of the transport.
> This means loopback must be added to virtio-vsock.
>
> The core net/vmware/af_vsock.c code does not implement loopback.  How
> does VMCI do loopback?  Are the loopback packets reflected back from the
> host?  Or does the guest driver notice the loopback and avoid passing
> packets to the host in the first place?
>
> Maybe we can make the loopback code common in af_vsock.c if that avoids
> code duplication.
>
> Thanks,
> Stefan
