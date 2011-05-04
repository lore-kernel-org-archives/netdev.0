From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v3 02/10] Revert "lsm: Remove the socket_post_accept() hook"
Date: Wed, 04 May 2011 10:50:38 +0200
Message-ID: <87k4e6n929.fsf@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<1304432663-1575-3-git-send-email-sam@synack.fr>
	<201105031802.34724.paul.moore@hp.com>
	<201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Wed, 4 May 2011 11:28:24 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Paul Moore wrote:
>> On Tuesday, May 03, 2011 10:24:15 AM Samir Bellabes wrote:
>> > snet needs to reintroduce this hook, as it was designed to be: a hook for
>> > updating security informations on objects.
>> 
>> Looking at this and 5/10 again, it seems that you should be able to do what 
>> you need with the sock_graft() hook.  Am I missing something?
>> 
>> My apologies if we've already discussed this approach previously ...
>
> Third problem (though independent with security_sock_graft()) is that
> snet_do_send_event() ignores snet_nl_send_event() failure.

using snet_do_send_event() means that system is sending data to
userspace. the system is not waiting for a verdict from userspace.

If error occurs, we actually loose the information data.
I may be able to write a solution which try to send the data again, but
we need a exit solution for this loop (a number of try ?).
