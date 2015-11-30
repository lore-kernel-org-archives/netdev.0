From: Richard Weinberger <richard@nod.at>
Subject: Re: user controllable usermodehelper in br_stp_if.c
Date: Tue, 1 Dec 2015 00:03:00 +0100
Message-ID: <565CD5A4.4010106@nod.at>
References: <565B7F7D.80208@nod.at>
	<CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	shayan@liveve.org
To: Kees Cook <keescook@chromium.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Am 30.11.2015 um 21:14 schrieb Kees Cook:
> On Sun, Nov 29, 2015 at 2:43 PM, Richard Weinberger <richard@nod.at> wrote:
>> Hi!
>>
>> By spawning new network and user namesapces an unprivileged user
>> is able to execute /sbin/bridge-stp within the initial mount namespace
>> with global root rights.
>> While this cannot directly be used to break out of a container or gain
>> global root rights it could be used by exploit writers as valuable building block.
>>
>> e.g.
>> $ unshare -U -r -n /bin/sh
>> $ brctl addbr br0
>> $ brctl stp br0 on # this will execute /sbin/bridge-stp
>>
>> As this mechanism clearly cannot work with containers and seems to be legacy code
>> I suggest not calling call_usermodehelper() at all if we're not in the initial user namespace.
>> What do you think?
> 
> I'm not familiar with how bridge-stp is expected to operate with a
> network namespace, but if it's meaningless, then yeah, that seems like
> a reasonable change. Can you send a patch? (Also, if it's legacy code,
> maybe it could be turned off entirely, not just for containers?)

Eric was faster than me. :-)

BTW: kernel.core_pattern is also worth a look.
If the pipe mode is used, "|/bin/core_tool", it will be executed in the
initial namespace and any user/container can trigger it.
Shayan reported that some weeks ago: https://lkml.org/lkml/2015/10/24/134

Thanks,
//richard
