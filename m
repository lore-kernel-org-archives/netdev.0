From: Andy Lutomirski <luto@kernel.org>
Subject: Food for thought: could cgroup+bpf live in a cgroup v1-compatible controller?
Date: Wed, 21 Dec 2016 15:55:17 -0800
Message-ID: <CALCETrUxamWYwGsLwCK_7XFQL4pRLGOGPt=-Qf36Lp6G2vpy6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        John Stultz <john.stultz@linaro.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems to be that all of the new cgroup+bpf hooks and all of the
proposed networking-related ones that I'm aware of look at
sock_cgroup_ptr().  I'm wondering if this could me made cgroup v1
compatible?

As far as I can tell, this could be done with no changes at all to the
networking code and only minor changes to the cgroup code.
Specifically, there would be a new "socket" controller.  Its effect
would be that cgroup_sk_alloc() would load the current socket cgroup
instead of the current default cgroup, assuming that a socket cgroup
were installed.

Would this work?  I realize that there a moratorium on new fields in
sock (for good reasons), but this would require a new field or even
have a significant effect on the meaning of existing fields.  Instead
it would just change how the cgroup that's loaded into the existing
field is selected.

Would this be doable?  If so, would it be useful?

(If this were done, then presumably cgroup+lsm+bpf would consider
becoming a controller as well.)

--Andy
