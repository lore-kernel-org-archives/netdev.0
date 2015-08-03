From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [PATCH 4/6] test_bpf: add module parameters to filter the tests
 to run.
Date: Mon, 03 Aug 2015 18:23:44 +0200
Message-ID: <55BF9590.4080205@freebox.fr>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-5-git-send-email-nschichan@freebox.fr> <55BF8F90.5030001@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55BF8F90.5030001@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 05:58 PM, Daniel Borkmann wrote:
> On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
>> When developping on the interpreter or a particular JIT, it can be
>> insteresting to restrict the test list to a specific test or a
> 
> s/insteresting/interesting/
[...]
> s/test_pbf/test_bpf/
[...]
> s/test_pbf/test_bpf/
[...]
> s/conver/cover/

Sorry for the various typos, I'll fix that in a V2.

>> +         */
>> +        if (test_id >= ARRAY_SIZE(tests)) {
>> +            pr_err("test_bpf: invalid test_id specified.\n");
>> +            return -EINVAL;
>> +        }
> [...]
>> @@ -4893,6 +4955,14 @@ static __init void destroy_bpf_tests(void)
>>       }
>>   }
>>
>> +static bool exclude_test(int test_id)
>> +{
>> +    if (test_range[0] >= 0 &&
>> +        (test_id < test_range[0] || test_id > test_range[1]))
>> +        return true;
>> +    return false;
> 
> Minor nit: could directly return it, f.e.:
> 
>     return test_range[0] >= 0 && (test_id < test_range[0] ||
>                                       test_id > test_range[1]);

I will change that.

> Btw, for the range test in prepare_bpf_tests(), you could also reject
> a negative lower bound index right there.

I thought it was better to have all the sanity checks grouped in
prepare_bpf_tests() (with the checking of the test_name and test_id parameters
nearby) ? Also a negative lower bound is meaning that no range has been set so
all tests should be run.

Thanks,

-- 
Nicolas Schichan
Freebox SAS
