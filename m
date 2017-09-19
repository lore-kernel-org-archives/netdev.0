From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 2/3] selftests: actually run the various net selftests
Date: Tue, 19 Sep 2017 09:34:25 -0400
Message-ID: <20170919133424.mzshgf67al7mv3fg@destiny>
References: <1505755982-7855-1-git-send-email-jbacik@fb.com>
 <1505755982-7855-2-git-send-email-jbacik@fb.com>
 <09f17145-5f0a-ec61-3dfb-69216eac7133@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josef@toxicpanda.com, Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
        netdev@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>,
        Shuah Khan <shuah@kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <09f17145-5f0a-ec61-3dfb-69216eac7133@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 04:14:41PM -0600, Shuah Khan wrote:
> On 09/18/2017 11:32 AM, josef@toxicpanda.com wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > These self tests are just self contained binaries, they are not run by
> > any of the scripts in the directory.  This means they need to be marked
> > with TEST_GEN_PROGS to actually be run, not TEST_GEN_FILES.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > ---
> >  tools/testing/selftests/net/Makefile | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
> > index 3df542c84610..45a4e77a47c4 100644
> > --- a/tools/testing/selftests/net/Makefile
> > +++ b/tools/testing/selftests/net/Makefile
> > @@ -6,8 +6,8 @@ CFLAGS += -I../../../../usr/include/
> >  TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh rtnetlink.sh
> >  TEST_GEN_FILES =  socket
> >  TEST_GEN_FILES += psock_fanout psock_tpacket
> > -TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
> > -TEST_GEN_FILES += reuseport_dualstack msg_zerocopy reuseaddr_conflict
> > +TEST_GEN_PROGS += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
> > +TEST_GEN_PROGS += reuseport_dualstack msg_zerocopy reuseaddr_conflict
> 
> Hmm. I see msg_zerocopy.sh for running msg_zerocopy. msg_zerocopy should
> still stay in TEST_GEN_FILES and msg_zerocopy.sh needs to be added to
> TEST_PROGS so it runs.
> 

Actually the shell script requires arguments, it doesn't just run the test.
I'll fix this to just omit the test for now as it's not setup to run properly.

Willem, could you follow up with a patch so that the zero copy test is run
properly the way you envision it running?  You need to make sure that

make -C tools/testing/selftests TARGETS=net run_tests

actually runs your zero copy test the way you expect it to, otherwise it's just
sitting there collecting dust.  Thanks,

Josef
