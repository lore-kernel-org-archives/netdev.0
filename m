From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: compile issue in latest iproute2
Date: Sat, 22 Apr 2017 18:18:58 +0200
Message-ID: <58FB8272.5080306@iogearbox.net>
References: <cecf76aa-2883-741e-1901-2f4850e2c188@mojatatu.com> <58FB7012.4080907@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44975 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425417AbdDVQTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:19:02 -0400
In-Reply-To: <58FB7012.4080907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2017 05:00 PM, Daniel Borkmann wrote:
> On 04/22/2017 02:31 PM, Jamal Hadi Salim wrote:
>>
>> I dont think is a kernel uapi - but it was failing compiling
>> when HAVE_ELF is false.
>> -----
>> jhs@jhs-UX:~/git-trees/others/iproute-with-ck$ git diff include/bpf_util.h
>> diff --git a/include/bpf_util.h b/include/bpf_util.h
>> index 5361dab..edca339 100644
>> --- a/include/bpf_util.h
>> +++ b/include/bpf_util.h
>> @@ -266,7 +266,7 @@ int bpf_send_map_fds(const char *path, const char *obj);
>>   int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
>>                       unsigned int entries);
>>   #else
>> -static inline int bpf_send_map_fds(const char *path, const char *obj)
>> +inline int bpf_send_map_fds(const char *path, const char *obj)
>>   {
>>          return 0;
>>   }
>> -----
>>
>> Let me know if you want a formal patch or feel free to take it.
>
> Will resolve it and send a patch later today, thanks!

Hmm, I'm on latest f443565f8df6 ("ip vrf: Add command name next to
pid") commit in master branch. Compiles fine for me with and without
ELF support. I verified that there's no HAVE_ELF defined and I'm
not seeing an error.

Without ELF support:

# ./configure
TC schedulers
  ATM	no

libc has setns: yes
SELinux support: yes
ELF support: no
libmnl support: yes
Berkeley DB: yes

docs: latex: yes
  pdflatex: yes
  sgml2latex: no
  WARNING: no LaTeX files can be build from SGML files
  sgml2html: no
  WARNING: no HTML docs can be built from SGML

# make > /dev/null
ssfilter.y: conflicts: 35 shift/reduce
#

With ELF support:

# ./configure
TC schedulers
  ATM	no

libc has setns: yes
SELinux support: yes
ELF support: yes
libmnl support: yes
Berkeley DB: yes

docs: latex: yes
  pdflatex: yes
  sgml2latex: no
  WARNING: no LaTeX files can be build from SGML files
  sgml2html: no
  WARNING: no HTML docs can be built from SGML

# make > /dev/null
ssfilter.y: conflicts: 35 shift/reduce
#

Anything I'm missing?
