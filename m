From: Sultan Qasim <sultanqasim@gmail.com>
Subject: Re: Mis-backport in af_unix patch for Linux 3.10.95
Date: Sun, 24 Jan 2016 11:16:25 -0500
Message-ID: <CAJLwaKb=uvay2Ht0-UbZzF03QmjwaZOVeJ+N+hTgSKbh61PJnA@mail.gmail.com>
References: <CAJLwaKa3vMzRnTt+JL7msQ33HZk_Jp+xMjOteBYCad46u15hKg@mail.gmail.com>
 <20160124083142.GA14045@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160124083142.GA14045@1wt.eu>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Thank you very much for the warm welcome :-)

You're right, the noblock variable is used elsewhere in the stream
receive function, so nothing is needed there after the interruptible
logic is restored for the dgram function.

Your patch looks good to me. I had picked the Linux 3.12.52 version of
the patch (where the interruptible locking was removed from the right
place in the stream receive function) onto my 3.10 kernel branch a
couple weeks ago and it has been working fine for me.

Thanks,
Sultan

On Sun, Jan 24, 2016 at 3:31 AM, Willy Tarreau <w@1wt.eu> wrote:
> Hello,
>
> On Sun, Jan 24, 2016 at 12:10:35AM -0500, Sultan Qasim wrote:
>> Hello all,
>>
>> I'm an outsider to the Linux kernel community, so I apologize if this
>> is not the right channel to mention this.
>
> The simple fact that you participate, inspect the code and report bugs
> makes you part of this community :-)  It's indeed the right place.
> Usually when reporting an issue with a commit, we also CC the whole
> signed-off-by / CC chain of that commit (which I'm doing now). For
> bugs related to networking, we usually CC the netdev list as well.
>
>> I noticed that the
>> backported version of the patch "af_unix: Revert 'lock_interruptible'
>> in stream receive code" in Linux 3.10.95 seems to have removed the
>> mutex_lock_interruptible from the wrong function.
>>
>> Here is the backported patch:
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=3a57e783016bf43ab9326172217f564941b85b17
>>
>> Here is the original:
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/net/unix/af_unix.c?id=3822b5c2fc62e3de8a0f33806ff279fb7df92432
>>
>> Was it not meant to be removed from unix_stream_recvmsg instead of
>> unix_dgram_recvmsg?
>
> You're absolutely right, good catch! Similar controls were added to
> both functions resulting in the same code appearing there, which
> confused the patch process, causing the change to be applied to the
> wrong location. This happens from time to time in such circumstances
> when backporting to older kernels.
>
>> Also, the variable called "noblock" needs to be
>> removed from the function being changed to prevent unused variable
>> warnings.
>
> If you mean this variable in function unix_dgram_recvmsg(), it would
> indeed report a warning but only due to the patch being mis-applied.
> In unix_stream_recvmsg(), it's still used as well.
>
> Does the attached patch seem better to you (not compile-tested) ?
>
> Greg/Ben, both 3.2.76 and 3.14.59 are OK regarding this, it seems
> like only 3.10.95 was affected.
>
> Thanks,
> Willy
>
