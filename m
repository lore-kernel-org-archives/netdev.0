From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix double free from dev_map_notification()
Date: Mon, 21 Aug 2017 02:47:55 +0200
Message-ID: <599A2DBB.2060305@iogearbox.net>
References: <22ff5f74079470a06e11940f40e05b2db74ca21f.1503272633.git.daniel@iogearbox.net> <52f70537-afcf-e384-cb96-2a5b8c032c51@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56641 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753427AbdHUAsA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 20:48:00 -0400
In-Reply-To: <52f70537-afcf-e384-cb96-2a5b8c032c51@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2017 02:42 AM, Alexei Starovoitov wrote:
> On 8/20/17 4:48 PM, Daniel Borkmann wrote:
[...]
> I wonder why it was done the other way around in the first place then?
> dev_map_list is there only for notifier and since the map is freed
> with all the devices totally makes sense to isolate it from notifier
> as a first step.

Yep, agree. Initially this was done by the mutex, but that was not
correct due to RCU for map helpers, of course.
