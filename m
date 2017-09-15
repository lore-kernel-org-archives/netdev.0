From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: selftests/bpf doesn't compile
Date: Fri, 15 Sep 2017 11:14:42 -0700
Message-ID: <20170915181440.adkgyqbt4yxrnbw7@ast-mbp>
References: <20170908111923.27434-1-thomas@m3y3r.de>
 <20170908230155.esge2mctk5d5g7gb@ast-mbp>
 <59B32231.9090406@iogearbox.net>
 <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org>
 <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
 <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
 <e07dabee-6c9c-7842-65b0-990a2ed1a2e9@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shuah Khan <shuah@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Meyer <thomas@m3y3r.de>, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Networking <netdev@vger.kernel.org>
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:46462 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdIOSOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 14:14:45 -0400
Content-Disposition: inline
In-Reply-To: <e07dabee-6c9c-7842-65b0-990a2ed1a2e9@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 11:00:31AM -0600, Shuah Khan wrote:
> >> I could add a special target for bpf TARGET_BPF perhaps and exclude it from
> >> the run_test> 
> > I'm not sure what was the motivation to exclude hotplug from default testing,
> 
> These are considered a bit more disruptive and were excluded a while
> back. These take cpus and memory on and off-line. Also require
> root access. So even if they are included in the regular run, these
> won't run.

most of bpf tests require root access as well.

> The first failure due to clang dependency is not a problem. The second one
> in the case of "make kselftest" is the one that requires some work when bpf
> make is run from the main Makefile. A lots of users run tests using the
> kselftest target from the mail Makefile. hence I would like to get this
> working, so it would be easier to run this test on test servers.

'make kselftest' doesn't work for me at all, since I suspect it
assumes in-source build. I always use KBUILD_OUTPUT,
since I build multiple archs with different configs out of the same
source tree, so there is a bigger problem here.

$ make kselftest
make[1]: Entering directory `/data/users/ast/net-next/bld_x64'
make: Entering an unknown directory
make: *** tools/testing/selftests: No such file or directory.  Stop.
make: Leaving an unknown directory
make[1]: *** [kselftest] Error 2
make[1]: Leaving directory `/data/users/ast/net-next/bld_x64'
make: *** [sub-make] Error 2
