From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Tue, 20 Oct 2015 11:44:51 -0700
Message-ID: <56268BA3.8020705@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org>
 <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org>
 <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net>
 <562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net>
 <5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com>
 <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>
 <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>
 <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>
 <56253335.9000206@plumgrid.com>
 <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
 <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
 <56255714.2070800@plumgrid.com>
 <1445295769.660392.414696249.0B413DF1@webmail.messagingengine.com>
 <56259438.3080308@plumgrid.com>
 <1445335671.822349.415077537.0691ED4C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445335671.822349.415077537.0691ED4C@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/15 3:07 AM, Hannes Frederic Sowa wrote:
> <off-topic>
> Just a pretty obvious idea is accurate sampling of flows.
> </off-topic>

ok, so you want to time out flows. Makes sense, but it should be
done by user space with little or none help from the kernel.

> fdinfo tells me where my position in a file is and which locks the file
> have?

obviously not. see the example fdinfo from the other email.

> So far, if someone wants to delve into the details of a map my approach
> would be to take the file descriptor and make it persistence. I have to
> think about that some more.

nope. you cannot do that. admin should never interfere with running
process this way.

> Yes, absolutely and I am absolutely against pretty printing key values
> in kernel domain.

let's table that part. I think it can be useful, but it's
irrelevant for this discussion.

> So cat-ing them will produce text output with some details about the
> map? This is what I wanted to avoid. The concept with symlinks and small
> files seems much cleaner and nicer to me. Also you cannot add writable
> attributes to this filesystem or you overload stuff heavily?

nope. no writeable stuff. fdinfo is read-only.

> It is not a tree but a graph, sure, that's why sysfs allows to break the
> cyclic dependencies and create symlinks (see holders/ directories). ;)

that's an obvious example of another resource waste.
You can do that for real devices, but for thousands of maps and programs
it is really a waste.

> And if you implement the same set of features IMHO you basically
> re-implement sysfs. In the beginning we just expose the basic maps and
> there won't be any features in sysfs, but it will be cheap to have
> read/write flags on maps etc. etc. (I don't know what people will come
> up with, yet.). In my opinion those are clearly attributes of a map and
> should be defined and managed alongside with their holders.

nope. bpf syscall is the only interface to access maps.
if we expose them in bpffs it will be read-only for debugging only.

> The pinfd feature will provide the future infrastructure alongside to
> make this usable, so I think it is worth spending time to think about
> it.

yes. but since we're going in circles, let's have a 'beer call' to
resolve it :)
