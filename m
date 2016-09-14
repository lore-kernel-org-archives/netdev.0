From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] [RFC] proc connector: add namespace events
Date: Wed, 14 Sep 2016 11:23:31 +0200
Message-ID: <20160914112331.0ee26a56@griffin>
References: <1473349086-31260-1-git-send-email-alban@kinvolk.io>
        <772621473716384@web6g.yandex.ru>
        <CAMXgnP4tNg1U5v1R3XEDp9jFKhX4n70iqiDmt1Vp5vySpO9LhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
        Alban Crequy <alban@kinvolk.io>, Tejun Heo <tj@kernel.org>,
        Aditya Kali <adityakali@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Iago Lopez Galeiras <iago@kinvolk.io>,
        "Serge E. Hallyn" <serge@hallyn.com>
To: Alban Crequy <alban.crequy@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMXgnP4tNg1U5v1R3XEDp9jFKhX4n70iqiDmt1Vp5vySpO9LhQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Sep 2016 16:42:43 +0200, Alban Crequy wrote:
> Note that I will probably not have the chance to spend more time on
> this patch soon because Iago will explore other methods with
> eBPF+kprobes instead. eBPF+kprobes would not have the same API
> stability though. I was curious to see if anyone would find the
> namespace addition to proc connector interesting for other projects.

Yes, this is a sorely missing feature. I don't care how this is done
(proc connector or something else) but the feature itself is quite
important for system management daemons. In particular, we need an
application that monitors network configuration changes on the machine,
displays the current configuration and records history of the changes.
This is currently impossible to do reliably if net name spaces are in
use - which they are with OpenStack and Docker and similar things in
place on those machines. The current tools try to do things like
monitoring /var/run/netns which is obviously unreliable and broken.

There are actually two (orthogonal) problems here: apart of the one
described above, it's also startup of such daemon. There's currently no
way to find all current name spaces from the user space. We'll need an
API for this, too.

And no, eBPF is not the answer. This should just work like any other
system daemon. I can't imagine that we would need llvm compiler and
kernel sources/debuginfo/whatever on every machine that runs such
daemon.

Thanks,

 Jiri
