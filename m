From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] userns: Add basic quota support v4
Date: Tue, 04 Sep 2012 22:20:27 -0700
Message-ID: <87fw6xnizo.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <87harqecvk.fsf@xmission.com>
	<20120827085034.GA8998@quack.suse.cz> <87wr0j7u3j.fsf_-_@xmission.com>
	<20120828090544.GC5146@quack.suse.cz> <87a9xe7wfn.fsf@xmission.com>
	<20120828175101.GF5146@quack.suse.cz> <87y5ky6dff.fsf_-_@xmission.com>
	<20120829021029.GC13691@dastard> <87r4qqnixd.fsf@xmission.com>
	<20120831011758.GH15292@dastard>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>,
	Alex Elder <elder@kernel.org>,
	Dmitry Monakhov <dmonakhov@openvz.org>,
	Abhijith Das <adas@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120831011758.GH15292@dastard> (Dave Chinner's message of "Fri,
	31 Aug 2012 11:17:58 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Dave Chinner <david@fromorbit.com> writes:

> On Wed, Aug 29, 2012 at 02:31:26AM -0700, Eric W. Biederman wrote:
>> 
>> Dave thanks for taking the time to take a detailed look at this code.
>> 
>> Dave Chinner <david@fromorbit.com> writes:
>> 
>> > On Tue, Aug 28, 2012 at 12:09:56PM -0700, Eric W. Biederman wrote:



>> > How did you test that this all works?
>> 
>> By making it a compile error if you get a conversion wrong and making it
>> a rule not to make any logic changes.
>>
>> That combined with code review
>> and running the code a bit to make certain I did not horribly mess up.
>
> But no actual regression testing. You're messing with code that I
> will have to triage when it goes wrong for a user, so IMO your code
> has to pass the same bar as the code I write has to pass for review
> - please regression test your code and write new regression tests
> for new functionality.

I like the idea of regression tests.  In practice and also with xfstests
I find that I spend lots of time debugging and fixing and improving
tests and at the end of the day I find regression tests tell me
very little.

But I did figure I should give them a try since I have a rather
substantial xfs patch in my queue.

I added tests 111 and 232 to the expunged file because the don't
run to completion.

ltp/rwtest.sh needs to be run with #!/bin/bash instead of #!/bin/sh as
it contains serveral bashisms.

You need to have gawk installed instead of mawk because of a non-posix
call to asort somewhere in the test framework.

On my branch userns-always-map-user-v53 or on v3.6-rc1+
xfs: check for possible overflow in xfs_ioc_trim
xfs: unlock the AGI buffer when looping in xfs_dialloc
xfs: fix uninitialised variable in xfs_rtbuf_get()

When I run ./check in the from xfstests I get

Tue Sep  4 05:06:12 PDT 2012
    001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 018
    019 020 021 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036
    037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054
    055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072
    073 074 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090
    091 092 093 094 095 096 097 098 099 100 101 102 103 104 105 106 107 108
    109 110 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127
    128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145
    146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163
    164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181
    182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199
    200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217
    218 219 220 221 222 223 224 225 226 227 228 229 230 231 233 234 235 236
    237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254
    255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272
    273 274 275 276 277 278 279 280 281 282 283 284 285 286
Not run:2
Failures: 018 081 082 106 107 136 167 171 206 219 229 234 250 280
Failed 14 of 165 tests

But since the results came back the same either way I think the tests
told me all they can.  The 14 failed tests and 1 bug don't seem to say
good things about xfs in general though.

Eric
