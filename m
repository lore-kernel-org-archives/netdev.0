From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Fri, 03 Feb 2017 22:09:46 +0100
Message-ID: <5894F19A.60305@iogearbox.net>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com> <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37832 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752530AbdBCVJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:09:59 -0500
In-Reply-To: <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 09:38 PM, David Ahern wrote:
> Similar to classic bpf, support saving original ebpf instructions
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Not convinced that this is in the right direction, this not only *significantly*
increases mem footprint for each and every program, but also when you dump this,
then map references from relocs inside the insns are meaningless (f.e. what about
prog arrays used in tail calls?), so things like criu also won't be able to use
this kind of interface for dump and restore. If it's just for debugging, then
why not extend the existing tracing infrastructure around bpf that was started
with intention to gain more visibility.

Thanks,
Daniel
