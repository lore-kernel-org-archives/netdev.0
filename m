From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 01/12] bpf: verifier: set reg_type on context
 accesses in second pass
Date: Thu, 12 Oct 2017 23:33:21 +0200
Message-ID: <59DFDFA1.3020809@iogearbox.net>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>        <20171012173418.4029-2-jakub.kicinski@netronome.com>    <59DFD3DE.9050907@iogearbox.net> <20171012135632.1fa408bc@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47055 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753203AbdJLVdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 17:33:23 -0400
In-Reply-To: <20171012135632.1fa408bc@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 10:56 PM, Jakub Kicinski wrote:
> On Thu, 12 Oct 2017 22:43:10 +0200, Daniel Borkmann wrote:
[...]
>> It would be nice to keep the reg_type setting in one place, meaning
>> the callbacks themselves, so we wouldn't need to maintain this in
>> multiple places.
>
> Hm.. I though this was the smallest and simplest change.  I could
> translate the offsets but that seems wobbly.  Or try to consolidate the
> call into the same if () branch?  Not sure..

Different callbacks for post-verification would be good at min as it
would allow to keep all the context access info in one place for a
given type at least.

> As a bonus info I discovered there is a bug in -net with how things are
> converted.  We allow arithmetic on context pointers but then only
> look at the insn.off in the converter...  I'm working on a fix.

Ohh well, good catch, indeed! :( Can you also add coverage to the
bpf selftests for this?

Thanks,
Daniel
