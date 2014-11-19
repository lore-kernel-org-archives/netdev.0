From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH v2 02/19] kbuild: kselftest_install - add a new make target
 to install selftests
Date: Wed, 19 Nov 2014 08:59:59 -0700
Message-ID: <546CBE7F.2090905@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com> <a2344d4df903d673afe1631118f40917f773cc9a.1415735831.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	dh.herrmann@gmail.com, hughd@google.com, bobby.prani@gmail.com,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: mmarek@suse.cz, ebiederm@xmission.com, serge.hallyn@ubuntu.com
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <a2344d4df903d673afe1631118f40917f773cc9a.1415735831.git.shuahkh@osg.samsung.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2014 01:27 PM, Shuah Khan wrote:
> Add a new make target to install to install kernel selftests.
> This new target will build and install selftests. kselftest
> target now depends on kselftest_install and runs the generated
> kselftest script to reduce duplicate work and for common look
> and feel when running tests.
> 
> Approach:
> 
> make kselftest_target:
> -- exports kselftest INSTALL_KSFT_PATH
>    default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
> -- exports path for ksefltest.sh
> -- runs selftests make install target:
> 
> selftests make install target
> -- creates kselftest.sh script in install install dir
> -- runs install targets for all INSTALL_TARGETS
>    (Note: ftrace and powerpc aren't included in INSTALL_TARGETS,
>           to not add more content to patch v1 series. This work
>           will happen soon. In this series these two targets are
>           run after running the generated kselftest script, without
>           any regression in the way these tests are run with
>           "make kselftest" prior to this work.)
> -- install target can be run only from top level source dir.
> 
> Individual test make install targets:
> -- install test programs and/or scripts in install dir
> -- append to the ksefltest.sh file to add commands to run test
> -- install target can be run only from top level source dir.
> 
> Adds the following new ways to initiate selftests:
> -- Installing and running kselftest from install directory
>    by running  "make kselftest"
> -- Running kselftest script from install directory
> 
> Maintains the following ways to run tests:
> -- make -C tools/testing/selftests run_tests
> -- make -C tools/testing/selftests TARGETS=target run_tests
>    Ability specify targets: e.g TARGETS=net
> -- make run_tests from tools/testing/selftests
> -- make run_tests from individual test directories:
>    e.g: make run_tests in tools/testing/selftests/breakpoints
> 
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> ---
>  Makefile | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)

Hi Marek,

Did you get a chance to take a look at this patch?

-- Shuah


-- 
Shuah Khan
Sr. Linux Kernel Developer
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
