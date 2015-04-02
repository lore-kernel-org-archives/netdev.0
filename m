From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Thu, 02 Apr 2015 12:19:32 +0200
Message-ID: <551D17B4.2090903@iogearbox.net>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net> <1427933636.1888890.248325033.0A76BE0D@webmail.messagingengine.com> <551C8C2D.5060504@iogearbox.net> <1427934556.1892386.248333013.431CD73B@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, tgraf@suug.ch,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50865 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbDBKTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 06:19:44 -0400
In-Reply-To: <1427934556.1892386.248333013.431CD73B@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2015 02:29 AM, Hannes Frederic Sowa wrote:
> On Thu, Apr 2, 2015, at 02:24, Daniel Borkmann wrote:
>> On 04/02/2015 02:13 AM, Hannes Frederic Sowa wrote:
>> ...
>>> Maybe a small utility programs like:
>>>
>>> bpf (--lookup|--update|--delete|--get-next-key) -fd
>>> filedescriptor-number (type conversion parameters here) key [value]
>>>
>>> So it can be easily used by shell scripts.
>>>
>>> For that the filedescriptor numbers would need to be exported (already
>>> opened) into a spawned shell and the numbers could be specified either
>>> in environment or just by printing text which can be sourced by shells
>>> (we already talked about the maybe exec 5</proc/pid/fd/1234 idea). Seems
>>> this can be just build ontop this current patch by extending the
>>> bpf-agent you already build, no?
>>
>> I was thinking about that and trying it out, but as far as I can tell,
>> due to the anon inodes that are currently underlying as the fd provider,
>> it doesn't work w/o larger kernel changes. So, the file descriptor
>> passing
>> is currently the only way to transfer control.
>
> Does receiving them via af_unix and spawning a new shell with the fds
> already open work?

I'm probably missing something, would that need changes to bash?

I mean exec could bind an fd in the shell to sockets and use that,
for example ...

   exec 3<>/dev/tcp/www.slashdot.org/80
   echo -e "GET / HTTP/1.1\r\nhost: http://www.slashdot.org\r\nConnection: close\r\n\r\n" >&3
   cat <&3

... perhaps such a built-in fake device for retrieving bpf map fds
might be interesting, e.g. exec 4<>/dev/bpf/<obj-file>/<map-name> if
that has been given to bash?

Anyway, I think to have some utility for shell scripts, as you
suggest, certainly sounds interesting!

Thanks,
Daniel
