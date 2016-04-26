From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 3/4] samples/bpf: add a README file to get users
 started
Date: Tue, 26 Apr 2016 14:40:54 +0200
Message-ID: <571F61D6.50101@iogearbox.net>
References: <20160426110828.20716.13392.stgit@firesoul>	<20160426110927.20716.89620.stgit@firesoul>	<571F5486.7090902@iogearbox.net> <20160426135647.7faf9a87@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com,
	borkmann@iogearbox.net, alexei.starovoitov@gmail.com,
	linux-kbuild@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20160426135647.7faf9a87@redhat.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26/2016 01:56 PM, Jesper Dangaard Brouer wrote:
> On Tue, 26 Apr 2016 13:44:06 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> On 04/26/2016 01:09 PM, Jesper Dangaard Brouer wrote:
>>> Getting started with using examples in samples/bpf/ is not
>>> straightforward.  There are several dependencies, and specific
>>> versions of these dependencies.
>>>
>>> Just compiling the example tool is also slightly obscure, e.g. one
>>> need to call make like:
>>>
>>>    make samples/bpf/
>>>
>>> Do notice the "/" slash after the directory name.
>>>
>>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>> ---
>>>    samples/bpf/README.rst |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
>>>    1 file changed, 67 insertions(+)
>>>    create mode 100644 samples/bpf/README.rst
>>>
>>> diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
>>> new file mode 100644
>>> index 000000000000..3e1ac05d8e7c
>>> --- /dev/null
>>> +++ b/samples/bpf/README.rst
>>> @@ -0,0 +1,67 @@
>>> +eBPF sample programs
>>> +====================
>>> +
>>> +This kernel samples/bpf directory contains a mini eBPF library, test
>>> +stubs, verifier test-suite and examples for using eBPF.
>>> +
>>> +Build dependencies
>>> +==================
>>> +
>>> +Compiling requires having installed:
>>> + * clang
>>> + * llvm >= version 3.7.0
>>> +
>>> +Note that LLVM's tool 'llc' must support target 'bpf', list with command::
>>> +
>>> + $ llc --version
>>> + LLVM (http://llvm.org/):
>>> +  LLVM version 3.x.y
>>> +  [...]
>>> +  Host CPU: xxx
>>> +
>>> +  Registered Targets:
>>> +    [...]
>>> +    bpf        - BPF (host endian)
>>> +    bpfeb      - BPF (big endian)
>>> +    bpfel      - BPF (little endian)
>>> +    [...]
>>> +
>>> +Kernel headers
>>> +--------------
>>> +
>>> +There are usually dependencies to header files of the current kernel.
>>> +To avoid installing devel kernel headers system wide, as a normal
>>> +user, simply call::
>>> +
>>> + make headers_install
>>> +
>>> +This will creates a local "usr/include" directory in the git/build top
>>> +level directory, that the make system automatically pickup first.
>>> +
>>> +Compiling
>>> +=========
>>> +
>>> +For compiling goto kernel top level build directory and run make like::
>>> +
>>> + make samples/bpf/
>>> +
>>> +Do notice the "/" slash after the directory name.
>>> +
>>> +Manually compiling LLVM with 'bpf' support
>>> +------------------------------------------
>>> +
>>> +In some LLVM versions the BPF target were marked experimental.  To
>>> +compile LLVM manually and enable BPF target run (build dependencies
>>> +are cmake and gcc-c++)::
>>> +
>>> + $ git clone http://llvm.org/git/llvm.git
>>> + $ cd llvm
>>> + $ mkdir build; cd build
>>> + $ cmake .. -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=BPF
>>> + $ make
>>
>> That's perhaps a bit misleading in the sense that when you clone the
>> tree from git, you'd nowadays invoke cmake normally with LLVM_TARGETS_TO_BUILD
>> instead of LLVM_EXPERIMENTAL_TARGETS_TO_BUILD for BPF, as BPF is not an
>> experimental target anymore. It's probably also recommended to clone
>> clang into tools/ dir as well under your llvm/ repo when you compile
>> from scratch anyways.
>
> Can you come up with a formulation/desc I can use instead then?

You mean how to build with clang? There are various docs/snippets out
there, for example, see the 'Build LLVM and Clang development libs'
part of [1], that you can tweak for your README with.

   [1] https://gist.github.com/brendangregg/cfa482acb71aa577789c
