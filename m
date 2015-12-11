From: Laura Abbott <labbott@redhat.com>
Subject: Re: [PATCH] iwlwifi: mvm: protect RCU dereference in
 iwl_mvm_get_key_sta_id
Date: Fri, 11 Dec 2015 14:21:19 -0800
Message-ID: <566B4C5F.4050908@redhat.com>
References: <566A0929.2090706@redhat.com>
 <1449821632-8106-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avri.altman@intel.com,
	emmanuel.grumbach@intel.com, linuxwifi@intel.com,
	linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449821632-8106-1-git-send-email-johannes@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2015 12:13 AM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> Properly protect the RCU dereference in iwl_mvm_get_key_sta_id() when
> coming from iwl_mvm_update_tkip_key() which cannot hold the mvm->mutex
> by moving the call into the RCU critical section.
> Modify the check to use rcu_dereference_check() to permit this.
>
> Fixes: 9513c5e18a0d ("iwlwifi: mvm: Avoid dereferencing sta if it was already flushed")
> Reported-by: Laura Abbott <labbott@redhat.com>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Thanks, it's working for me.

Tested-by: Laura Abbott <labbott@redhat.com>
