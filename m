From: Tejun Heo <tj@kernel.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Wed, 18 Jan 2017 14:18:50 -0800
Message-ID: <20170118221850.GF9171@mtj.duckdns.org>
References: <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
 <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <20161220091150.GJ3124@twins.programming.kicks-ass.net>
 <20170103102559.GA30129@dhcp22.suse.cz>
 <20170116011901.GH14446@mtj.duckdns.org>
 <20170117130303.GL19699@dhcp22.suse.cz>
 <20170117133204.GA6515@twins.programming.kicks-ass.net>
 <20170117135830.GO19699@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
        Andy Lutomirski <luto@amacapital.net>,
        David Ahern <dsahern@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170117135830.GO19699@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Michal.

On Tue, Jan 17, 2017 at 02:58:30PM +0100, Michal Hocko wrote:
> This would require using hierarchical cgroup iterators to iterate over

It does behave hierarchically.

> tasks. As per Andy's testing this doesn't seem to be the case. I haven't

That's not what Andy's testing showed.  What that showed was that
program in a child can override the one from its ancestor.

> checked the implementation closely but my understanding was that using
> only cgroup specific tasks was intentional.

Maybe I'm misreading you but if you're saying that a bpf program would
only execute for tasks on that specific cgroup, that is not true.

> I do agree that using hierarchy aware cgroup iterators is the right
> approach here and we wouldn't see any issue. But I am still not sure
> I've wrapped my head around this feature completely.

It's really simple.  You can install bpf programs with a cgroup path
associated with them.  When that particular type of bpf program needs
to be executed, the bpf program which is attached to the closest
ancestor (including self) is executed.

Thanks.

-- 
tejun
